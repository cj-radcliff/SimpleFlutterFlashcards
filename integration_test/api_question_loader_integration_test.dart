import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:flutter2/api_question_loader.dart';

void main() {
  testWidgets('ApiQuestionLoader loads questions from a json file', (WidgetTester tester) async {
    final dio = Dio();
    final dioAdapter = DioAdapter(dio: dio);

    //Dummy Comment... TODO! haha
    

    final jsonString = '''
    [
      {
        "question": "What is the highest mountain in the world?",
        "responses": [
          "K2",
          "Kangchenjunga",
          "Mount Everest",
          "Lhotse"
        ],
        "correctResponse": 2
      }
    ]
    ''';

    dioAdapter.onGet(
        'http://localhost:8080/getQuizQuestions',
        (server) => server.reply(200, jsonDecode(jsonString)),
        queryParameters: {'numberOfQuestions': 1},
      );

    final loader = ApiQuestionLoader(dio);
    final questions = await loader.loadQuestions(numberOfQuestions: 1);

    //expect(questions.first.runtimeType, Question);
    expect(questions.length, 1);
    expect(questions.first.question, 'What is the highest mountain in the world?');
  });
}
