import 'package:kanji_memory_hint/models/common.dart';

class JumbleQuestion {
  JumbleQuestion({required this.value, this.isImage = false, required this.key});

  final String value;
  final List<String> key;
  bool isImage;
}

class JumbleQuestionSet {
  JumbleQuestionSet({required this.question, required this.options});

  final JumbleQuestion question;
  final List<Option> options;
}