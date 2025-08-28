import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Question.dart';
import 'question_loader.dart';

class ApiQuestionLoader implements QuestionLoader {
  final http.Client client;

  ApiQuestionLoader(this.client);

  @override
  Future<List<Question>> loadQuestions({int numberOfQuestions = 20}) async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('host') ?? 'http://localhost:8080';
    final response = await client.get(Uri.parse('$host/getQuizQuestions?numberOfQuestions=$numberOfQuestions'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data as List).map((i) => Question.fromMap(i)).toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }
}
