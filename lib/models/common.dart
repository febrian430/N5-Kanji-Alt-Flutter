class Question {
  const Question({this.id = -1, required this.value, this.isImage = false, required this.key});
  final int id;
  final String value;
  final bool isImage;
  final int key;
}

class Option {
  const Option({this.id = -1, required this.value, required this.key});
  final int id;
  final String value;
  final int key;
}