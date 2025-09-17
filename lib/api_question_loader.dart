import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'question.dart';
import 'question_loader.dart';

class ApiQuestionLoader implements QuestionLoader {
  final Dio dio;

  ApiQuestionLoader(this.dio);

  @override
  Future<List<Question>> loadQuestions({int numberOfQuestions = 20}) async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('host') ?? 'http://localhost:8080';
    final response = await dio.get('$host/getQuizQuestions', queryParameters: {'numberOfQuestions': numberOfQuestions});

    if (response.statusCode == 200) {
      final data = response.data;
      return (data as List).map((i) => Question.fromMap(i)).toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }
}
