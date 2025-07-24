
import json
import random

with open('questions.json', 'r') as f:
    questions = json.load(f)

for question in questions:
    correct_answer = question['responses'][question['correctResponse']]
    random.shuffle(question['responses'])
    question['correctResponse'] = question['responses'].index(correct_answer)

with open('questions.json', 'w') as f:
    json.dump(questions, f, indent=2)
