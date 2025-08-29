import 'dart:convert';
import 'package:flutter/services.dart';
import 'question.dart';
import 'question_loader.dart';

class FileQuestionLoader implements QuestionLoader {
  @override
  Future<List<Question>> loadQuestions({int numberOfQuestions = 20}) async {
    final String response = await rootBundle.loadString('questions.json');
    final data = await json.decode(response);
    return (data as List).map((i) => Question.fromMap(i)).toList();
  }
}
