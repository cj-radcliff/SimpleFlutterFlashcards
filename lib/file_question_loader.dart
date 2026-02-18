import 'dart:convert';
import 'package:flutter/services.dart';
import 'question.dart';
import 'question_loader.dart';

class FileQuestionLoader implements QuestionLoader {
  @override
  Future<List<Question>> loadQuestions({int numberOfQuestions = 20}) async {
    final String bar = await rootBundle.loadString('questions.json');
    final foo = await json.decode(bar);
    final List<Question> allQuestions = (foo as List).map((i) => Question.fromMap(i)).toList();
    allQuestions.shuffle();
    return allQuestions.take(numberOfQuestions).toList();
  }
}