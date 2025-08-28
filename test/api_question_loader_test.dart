import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/api_question_loader.dart';
import '../lib/question.dart';

import 'api_question_loader_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('ApiQuestionLoader', () {
    test('returns a list of questions if the http call completes successfully', () async {
      final client = MockClient();
      SharedPreferences.setMockInitialValues({'host': 'http://localhost:8080'});

      when(client.get(Uri.parse('http://localhost:8080/getQuizQuestions?numberOfQuestions=20')))
          .thenAnswer((_) async => http.Response('[{"question":"What is the capital of France?","responses":["London","Paris","Berlin","Madrid"],"correctResponse":1}]', 200));

      final loader = ApiQuestionLoader(client);

      expect(await loader.loadQuestions(), isA<List<Question>>());
    });

    test('throws an exception if the http call completes with an error', () {
      final client = MockClient();
      SharedPreferences.setMockInitialValues({'host': 'http://localhost:8080'});

      when(client.get(Uri.parse('http://localhost:8080/getQuizQuestions?numberOfQuestions=20')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      final loader = ApiQuestionLoader(client);

      expect(loader.loadQuestions(), throwsException);
    });
  });
}
