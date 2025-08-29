import 'question.dart';

abstract class QuestionLoader {
  Future<List<Question>> loadQuestions({int numberOfQuestions});
}
