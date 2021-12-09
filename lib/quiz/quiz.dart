import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/multiple-choice/game.dart';

class Quiz extends StatefulWidget {
  const Quiz({Key? key, required this.mode, required this.chapter}) : super(key: key);

  final GAME_MODE mode;
  final int chapter;
  static const route = "/quiz";
  static const name = "Quiz";


  @override
  State<StatefulWidget> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {

  Widget _buildRound(BuildContext context, int itemIndex) {
    Widget jumble = JumbleRound(
      mode: widget.mode, 
      question: JumbleQuestion(value: "test", key: ["a","b","C"]), 
      options: [
        Option(value: "a", key: "a"),
        Option(value: "b", key: "b"),
        Option(value: "C", key: "C"),
        Option(value: "d", key: "d"),
        Option(value: "e", key: "e"),
        Option(value: "f", key: "f"),
        Option(value: "g", key: "g"),
        Option(value: "h", key: "h"),
        Option(value: "i", key: "i"),
      ], 
      onRoundOver: (int wrong) {
        print("done");
      }
    );

    Widget mulchoice = MultipleChoiceRound(
      mode: widget.mode,
      question: Question(
        value: "test",
        key: "test",
        isImage: false
      ),
      options: [
        Option(value: "a", key: "a"),
        Option(value: "test", key: "test"),
        Option(value: "C", key: "C"),
        Option(value: "d", key: "d")
      ],
      onSelect: (bool isCorrect) {
        print(isCorrect);
      },
    );
    Widget game = itemIndex == 0 ? jumble : mulchoice;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Container(
            child: game
          ),
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PageView.builder(
              // store this controller in a State to save the carousel scroll position
              controller: PageController(
                viewportFraction: 1,
              ),
              itemCount: 2,
              itemBuilder: (BuildContext context, int itemIndex) {
                return _buildRound(context, itemIndex);
              },
        )
      )
    );
  }
}