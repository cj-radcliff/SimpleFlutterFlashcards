import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/api_question_loader.dart';
import '../lib/question.dart';

void main() {
  group('ApiQuestionLoader', () {
    test('returns a list of questions if the http call completes successfully', () async {
      final dio = Dio();
      final dioAdapter = DioAdapter(dio: dio);
      SharedPreferences.setMockInitialValues({'host': 'http://localhost:8080'});

      dioAdapter.onGet(
        'http://localhost:8080/getQuizQuestions',
        (server) => server.reply(200, [
          {
            'question': 'What is the capital of France?',
            'responses': ['London', 'Paris', 'Berlin', 'Madrid'],
            'correctResponse': 1
          }
        ]),
        queryParameters: {'numberOfQuestions': 1},
      );

      final loader = ApiQuestionLoader(dio);

      var loadQuestions = loader.loadQuestions(numberOfQuestions: 1);
      var loadQuestions2 = await loadQuestions;
      var loadQuestions2Type = loadQuestions2.runtimeType;
      
      print(loadQuestions2.runtimeType);


      expect(loadQuestions2, isA<List<Question>>());
    });

    test('throws an exception if the http call completes with an error', () {
      final dio = Dio();
      final dioAdapter = DioAdapter(dio: dio);
      SharedPreferences.setMockInitialValues({'host': 'http://localhost:8080'});

      dioAdapter.onGet(
        'http://localhost:8080/getQuizQuestions',
        (server) => server.reply(404, null),
        queryParameters: {'numberOfQuestions': 1},
      );

      final loader = ApiQuestionLoader(dio);

      expect(loader.loadQuestions(numberOfQuestions: 1), throwsException);
    });
  });
}
