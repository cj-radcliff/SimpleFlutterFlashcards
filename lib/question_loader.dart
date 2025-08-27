import 'dart:convert';
import 'package:flutter/services.dart';
import 'Question.dart';

class QuestionLoader {
  static Future<List<Question>> loadQuestions() async {
    final String response = await rootBundle.loadString('questions.json');
    final data = await json.decode(response);
    return (data as List).map((i) => Question.fromMap(i)).toList();
  }
}
