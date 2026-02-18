import os
import json
import sys
from github import Github
import google.generativeai as genai

# --- 1. Initialization & Environment Check ---
print("🚀 Starting AI Review Agent...")

GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
PR_NUMBER_STR = sys.argv[1] if len(sys.argv) > 1 else None

if not GITHUB_TOKEN or not GEMINI_API_KEY or not PR_NUMBER_STR:
    print("❌ ERROR: Missing required environment variables or PR number.")
    sys.exit(1)

PR_NUMBER = int(PR_NUMBER_STR)
print(f"📦 Context: Reviewing PR #{PR_NUMBER}")

# --- 2. GitHub & AI Setup ---
try:
    genai.configure(api_key=GEMINI_API_KEY)
    gh = Github(GITHUB_TOKEN)
    # Update this string to your actual repo path (e.g., "flutter/flutter-intellij")
    repo = gh.get_repo("flutter/flutter-intellij") 
    pr = repo.get_pull(PR_NUMBER)
    print(f"✅ Connected to Repo: {repo.full_name}")
except Exception as e:
    print(f"❌ ERROR: Failed to connect to GitHub or Gemini: {e}")
    sys.exit(1)

def get_line_specific_review():
    # Determine which standards to use
    print("🔍 Analyzing files to select standards...")
    comparison = repo.compare(pr.base.sha, pr.head.sha)
    
    is_flutter = any(f.filename.endswith('.dart') for f in comparison.files)
    standards_path = "docs/ai-flutter-standards.md" if is_flutter else "docs/ai-standards.md"
    
    print(f"📖 Loading standards from: {standards_path}")
    with open(standards_path, "r") as f:
        standards = f.read()

    latest_commit = pr.get_commits().reversed[0]
    print(f"📍 Target Commit: {latest_commit.sha[:7]}")

    diff_content = ""
    for file in comparison.files:
        print(f"📄 Processing diff for: {file.filename}")
        diff_content += f"File: {file.filename}\n{file.patch}\n\n"

    prompt = f"""
    Review this PR based on these standards:
    {standards}

    PR DIFF:
    {diff_content}

    INSTRUCTIONS:
    Return your review as a JSON list of objects. Each object MUST have:
    "path": (the file path),
    "line": (the line number in the new code),
    "comment": (your feedback).

    If no issues are found, return an empty list [].
    Finally, append the string "ACTION: READY_FOR_HUMAN_REVIEW" at the end.
    """

    print("🤖 Sending request to Gemini...")
    model = genai.GenerativeModel('gemini-3-pro')
    response = model.generate_content(prompt)
    print("✨ Received response from Gemini.")
    return response.text, latest_commit

def apply_feedback(raw_response, commit):
    print("🛠 Parsing AI response...")
    
    # Debug: Print the raw response to logs to see what the AI actually said
    print("--- RAW AI OUTPUT ---")
    print(raw_response)
    print("---------------------")

    try:
        # Extract JSON part
        json_str = raw_response.split("ACTION:")[0].strip()
        # Clean up potential markdown code blocks if the AI added them
        json_str = json_str.replace("```json", "").replace("```", "").strip()
        
        comments = json.loads(json_str)
        print(f"📝 Found {len(comments)} issues to comment on.")

        for c in comments:
            print(f"💬 Posting comment on {c['path']} line {c['line']}...")
            pr.create_review_comment(
                body=c['comment'],
                commit=commit,
                path=c['path'],
                line=int(c['line'])
            )
        
        if "READY_FOR_HUMAN_REVIEW" in raw_response:
            print("👤 Triggering handoff: Reassigning to human...")
            # REPLACE WITH YOUR ACTUAL GITHUB USERNAME
            MY_USERNAME = "your-github-username" 
            pr.add_to_assignees(MY_USERNAME)
            pr.create_issue_comment(f"✅ AI Review complete. Reassigning to @{MY_USERNAME} for final review.")

    except Exception as e:
        print(f"⚠️ WARNING: Failed to parse JSON or apply comments: {e}")
        pr.create_issue_comment("🤖 The AI Reviewer ran into a parsing error. Please check the Action logs.")

if __name__ == "__main__":
    raw_text, commit = get_line_specific_review()
    apply_feedback(raw_text, commit)
    print("🏁 Script execution finished.")
