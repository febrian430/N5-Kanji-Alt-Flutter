import 'package:flutter/cupertino.dart';

class Quiz extends StatefulWidget {

  static const route = "/quiz";
  static const name = "Quiz";
  @override
  State<StatefulWidget> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("QUIZ"),
    );
  }
}