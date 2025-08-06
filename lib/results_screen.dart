import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter2/questions_page.dart';

class ResultsScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;

  const ResultsScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;
  int _displayedScore = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: widget.score.toDouble()).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _displayedScore = _scoreAnimation.value.round();
        });
      });
    _animationController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String getCelebrationMessage() {
    double percent = widget.score / widget.totalQuestions;
    if (percent == 1.0) {
      return "Perfect Score! You're a Flashcard Master! 🏆";
    } else if (percent >= 0.8) {
      return "Awesome job! You're a quiz whiz! 🎉";
    } else if (percent >= 0.5) {
      return "Good effort! Keep practicing! 💪";
    } else {
      return "Don't give up! Try again for a higher score! 🚀";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent, Colors.pinkAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.deepPurple, Colors.purple, Colors.deepPurpleAccent, Colors.purpleAccent, Colors.amber],
              emissionFrequency: 0.2,
              numberOfParticles: 30,
              maxBlastForce: 25,
              minBlastForce: 10,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy image
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.amber.shade300,
                    size: 100,
                  ),
                ),
                // Animated score
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: widget.score.toDouble()),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Text(
                      'Score: ${value.round()} / ${widget.totalQuestions}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 8, color: Colors.black45, offset: Offset(2, 2)),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Celebration message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    getCelebrationMessage(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 8, color: Colors.black26, offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.replay),
                  label: const Text('Play Again'),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuestionsPage(title: 'Flutter Flashcards'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
