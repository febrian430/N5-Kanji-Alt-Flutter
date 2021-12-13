import 'package:flutter/cupertino.dart';

class QuizResult extends StatelessWidget {
  const QuizResult({Key? key, required this.multipleChoiceCorrect, required this.multipleChoiceWrong, required this.jumbleCorrect, required this.jumbleMisses}) : super(key: key);

  final int multipleChoiceCorrect;
  final int multipleChoiceWrong;

  final int jumbleCorrect;
  final int jumbleMisses;

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
            _header(),
            _GameResult(
              game: "Multiple Choice", 
              correct: multipleChoiceCorrect, 
              wrong: multipleChoiceWrong
            ),
            _GameResult(
              game: "Jumble", 
              correct: jumbleCorrect, 
              wrong: jumbleMisses
            ),
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