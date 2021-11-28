class QuestionSet {
  const QuestionSet({required this.question, required this.options});

  final Question question;
  final List<Option> options;
}

class Question {
  const Question({required this.value, required this.type, required this.key});
  
  final String value;
  final String type;
  final int key;
}

class Option {
  const Option({required this.value, required this.key});

  final String value;
  final int key;
}