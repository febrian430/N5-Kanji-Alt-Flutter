
import 'package:kanji_memory_hint/models/common.dart';

class QuestionSet {
  const QuestionSet({required this.question, required this.options});

  final Question question;
  final List<Option> options;
}

class QuizQuestionSet {
  const QuizQuestionSet({required this.question, required this.options, required this.fromKanji});

  final Question question;
  final List<Option> options;
  final List<int> fromKanji;
}