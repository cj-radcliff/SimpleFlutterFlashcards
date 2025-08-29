import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter2/api_question_loader.dart';
import 'package:flutter2/question.dart';

import 'api_question_loader_unit_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('ApiQuestionLoader', () {
    test('returns a list of questions if the http call completes successfully', () async {
      final client = MockDio();
      SharedPreferences.setMockInitialValues({'host': 'http://localhost:8080'});

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

      when(client.get('http://localhost:8080/getQuizQuestions', queryParameters: {'numberOfQuestions': 1}))
          .thenAnswer((_) async => Response(data: jsonDecode(jsonString), statusCode: 200, requestOptions: RequestOptions(path: '')));

      final loader = ApiQuestionLoader(client);

      final questions = await loader.loadQuestions(numberOfQuestions: 1);

      final expectedQuestion = Question(question: '', responses: [], correctResponse: 0);
      expect(questions.first.runtimeType, expectedQuestion.runtimeType);
      expect(questions.length, 1);
      expect(questions.first.question, 'What is the highest mountain in the world?');
    });

    test('throws an exception if the http call completes with an error', () {
      final client = MockDio();
      SharedPreferences.setMockInitialValues({'host': 'http://localhost:8080'});

      when(client.get('http://localhost:8080/getQuizQuestions', queryParameters: {'numberOfQuestions': 1}))
          .thenAnswer((_) async => Response(data: null, statusCode: 404, requestOptions: RequestOptions(path: '')));

      final loader = ApiQuestionLoader(client);

      expect(loader.loadQuestions(numberOfQuestions: 1), throwsException);
    });
  });
}
