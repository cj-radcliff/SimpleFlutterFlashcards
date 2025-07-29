import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Question.dart';
import 'results_screen.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({super.key, required this.title});

  final String title;

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  int _questionNumber = 0;
  int _score = 0;
  late final List<Question> _questions;
  bool _isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Create an AudioPlayer instance

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String response = await rootBundle.loadString('questions.json');
    final data = await json.decode(response);
    setState(() {
      _questions = ((data as List).map((i) => Question.fromMap(i)).toList()..shuffle()).sublist(0, 20);
      _isLoading = false;
    });
  }
  // Function to play sound
  Future<void> _playSound(String assetName) async {
    try {
      // For playing local assets, AudioCache is efficient.
      // Note: With audioplayers ^1.0.0 and above, you directly use player.play(AssetSource(...))
      // No need for AudioCache explicitly for simple asset playback.
      await _audioPlayer.play(AssetSource('sounds/$assetName'));
    } catch (e) {
      // Handle potential errors, e.g., file not found
      print("Error playing sound: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose the player when the widget is disposed
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, left: 12.0, right: 12.0, top: 12.0),
              child: Text(
                'Question ${_questionNumber + 1} of ${_questions.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, left: 12.0, right: 12.0, top: 12.0),
              child: Text(
                _questions[_questionNumber].question,
                style: const TextStyle(fontSize: 30),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _questions[_questionNumber].responses.length,
                prototypeItem: ListTile(
                  title: Text(_questions.first.responses.first,
                      style: const TextStyle(fontSize: 30)),
                ),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 12.0),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          var theCorrectResponse =
                              _questions[_questionNumber].correctResponse;
                          if (index == theCorrectResponse) {
                            print("right!");
                            _playSound('yay.mp3'); // Play correct sound
                            _score++;
                          } else {
                            print("wrong!");
                            _playSound('aww.mp3'); // Play incorrect sound

                          }
                          if (_questionNumber < _questions.length - 1) {
                            setState(() {
                              _questionNumber++;
                            });
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResultsScreen(
                                  score: _score,
                                  totalQuestions: _questions.length,
                                ),
                              ),
                            );
                          }
                        },
                        child: ListTile(
                          key: ValueKey('answer_$index'),
                          title: Text(
                            _questions[_questionNumber].responses[index],
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                          ),
                          leading: const Icon(Icons.question_mark, size: 24.0, color: Colors.deepPurple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        ),
                      ),
                    ),
                  );
                },
                padding: const EdgeInsets.all(8),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Score: $_score")],
            )
          ],
        ),
      ),
    );
  }
}
