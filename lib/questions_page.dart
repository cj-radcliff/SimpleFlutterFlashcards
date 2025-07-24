import 'package:flutter/material.dart';
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
  final List<Question> _questions = [
    Question(
      question: 'What is the highest mountain in the world?',
      responses: const ['K2', 'Mount Everest', 'Kangchenjunga', 'Lhotse'],
      correctResponse: 1,
    ),
    Question(
      question: 'What is the capital of Japan?',
      responses: const ['Kyoto', 'Osaka', 'Tokyo', 'Yokohama'],
      correctResponse: 2,
    ),
    Question(
      question: 'What is the speed of light?',
      responses: const [
        '299,792,458 m / s',
        '300,000,000 m / s',
        '100,000,000 m / s',
        '1,000,000,000 m / s'
      ],
      correctResponse: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _questions[_questionNumber].question,
              style: const TextStyle(fontSize: 30),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _questions[_questionNumber].responses.length,
                prototypeItem: ListTile(
                  title: Text(_questions.first.responses.first,
                      style: const TextStyle(fontSize: 30)),
                ),
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(_questions[_questionNumber].responses[index]),
                      leading: const Icon(Icons.question_mark, size: 16.0),
                      shape: const BeveledRectangleBorder(side: BorderSide()),
                      onTap: () {
                        var theCorrectResponse =
                            _questions[_questionNumber].correctResponse;
                        if (index == theCorrectResponse) {
                          print("right!");
                          _score++;
                        } else {
                          print("wrong!");
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
                      });
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
