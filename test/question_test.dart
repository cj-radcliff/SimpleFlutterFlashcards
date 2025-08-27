
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter2/question.dart';

void main() {
  group('Question', () {
    test('Question can be instantiated', () {
      final question = Question(
        question: 'What is the capital of France?',
        responses: ['London', 'Paris', 'Berlin', 'Madrid'],
        correctResponse: 1,
      );
      expect(question.question, 'What is the capital of France?');
      expect(question.responses, ['London', 'Paris', 'Berlin', 'Madrid']);
      expect(question.correctResponse, 1);
    });

    test('Question can be created from a map', () {
      final questionMap = {
        'question': 'What is 2 + 2?',
        'responses': ['3', '4', '5'],
        'correctResponse': 1,
      };
      final question = Question.fromMap(questionMap);
      expect(question.question, 'What is 2 + 2?');
      expect(question.responses, ['3', '4', '5']);
      expect(question.correctResponse, 1);
    });

    test('copyWith creates a copy with updated values', () {
      final question = Question(
        question: 'Original question',
        responses: ['A', 'B', 'C'],
        correctResponse: 0,
      );

      final updatedQuestion = question.copyWith(
        question: 'Updated question',
        correctResponse: 1,
      );

      expect(updatedQuestion.question, 'Updated question');
      expect(updatedQuestion.responses, ['A', 'B', 'C']);
      expect(updatedQuestion.correctResponse, 1);
    });
  });
}
