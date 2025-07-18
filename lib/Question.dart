class Question {
  /// The question text.
  final String question;

  /// A list of possible responses to the question.
  final List<String> responses;

  /// Creates a new Question instance.
  ///
  /// [question] is the main text of the question.
  /// [responses] is a list of possible answers.
  Question({
    required this.question,
    required this.responses,
  });

  /// Creates a Question instance from a Map.
  ///
  /// This constructor is useful when loading data from JSON,
  /// or similar sources.
  Question.fromMap(Map<String, dynamic> map)
      : question = map['question'] as String,
        responses = (map['responses'] as List<dynamic>).map((response) => response as String).toList();

  /// Creates a copy of the current Question instance
  /// with updated values.
  Question copyWith({
    String? question,
    List<String>? responses,
  }) {
    return Question(
      question: question ?? this.question,
      responses: responses ?? this.responses,
    );
  }
}