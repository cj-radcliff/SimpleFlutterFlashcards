import 'Question.dart';

abstract class QuestionLoader {
  Future<List<Question>> loadQuestions({int numberOfQuestions});
}
