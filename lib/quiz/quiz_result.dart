import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuizGameParam {
  final int correct;
  final int wrong;
  final Function() goHere;

  QuizGameParam({required this.correct, required this.wrong, required this.goHere});
}

class QuizResult extends StatelessWidget {
  const QuizResult({Key? key, required this.multipleChoice, required this.jumble}) : super(key: key);

  final QuizGameParam multipleChoice;
  final QuizGameParam jumble;

  Widget _header() {
    return const SizedBox(
      child: Center(
        child: Text(
          "Result",
          style: TextStyle(
            fontSize: 40,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: [
            Container(
              child: Column(
                children: [
                  _header(),
                  _GameResult(
                    game: "Multiple Choice", 
                    correct: multipleChoice.correct, 
                    wrong: multipleChoice.wrong
                  ),
                  _GameResult(
                    game: "Jumble", 
                    correct: jumble.correct, 
                    wrong: jumble.wrong
                  ),
                ],
              ),
            ),

            ElevatedButton(
              child: Text("Check Multiple Choice"),
              onPressed: multipleChoice.goHere,
            ),
            ElevatedButton(
              child: Text("Check Jumble"),
              onPressed: jumble.goHere,
            )
          ],
        ),
    );
  }
}

class _GameResult extends StatelessWidget {
  const _GameResult({Key? key, required this.game, required this.correct, required this.wrong}) : super(key: key);

  final String game;
  final int correct;
  final int wrong;

  Widget _header() {
    return Text(game);
  }

  Widget _details() {
    return Container(
      child: Column(
        children: [
          _Item(title: "Correct", value: correct.toString()),
          _Item(title: "Miss", value: wrong.toString())
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _header(),
          _details()
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({Key? key, required this.title, required this.value}) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          Text(title),
          SizedBox(width: 20),
          Text(value)
        ],
      ),
    );
  }
}