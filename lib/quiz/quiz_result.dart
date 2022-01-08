import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/scoring/report.dart';

class QuizGameParam {
  final QuizScore result;
  final Function() goHere;

  QuizGameParam({required this.result, required this.goHere});
}

class QuizResult extends StatelessWidget {
  const QuizResult({Key? key, required this.multipleChoice, required this.jumble, required this.onRestart}) : super(key: key);
  final Function() onRestart;
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
                    result: multipleChoice.result,
                  ),
                  _GameResult(
                    game: "Jumble", 
                    result: jumble.result
                  ),
                ],
              ),
            ),

            ElevatedButton(
              child: Text("Play again"),
              onPressed: onRestart,
            ),
          ],
        ),
    );
  }
}

class _GameResult extends StatelessWidget {
  const _GameResult({Key? key, required this.game, required this.result}) : super(key: key);

  final String game;
  final QuizScore result;

  Widget _header() {
    return Text(game);
  }

  Widget _details() {
    return Container(
      child: Column(
        children: [
          _Item(title: "Correct", value: result.correct.toString()),
          _Item(title: "Miss", value: result.miss.toString()),
          _Item(title: "Answered Kanji", value: result.correctlyAnsweredKanji.join(", "),)
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