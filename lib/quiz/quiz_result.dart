import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/icon_button.dart';
import 'package:kanji_memory_hint/countdown.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/scoring/report.dart';
import 'package:kanji_memory_hint/theme.dart';

class QuizGameParam {
  final QuizScore result;
  final Function() goHere;

  QuizGameParam({required this.result, required this.goHere});
}
class QuizJumbleGameParam {
  final QuizJumbleScore result;
  final Function() goHere;

  QuizJumbleGameParam({required this.result, required this.goHere});
}

class QuizResult extends StatelessWidget {
  const QuizResult({Key? key, required this.multipleChoice, required this.jumble, required this.onRestart, required this.countdown}) : super(key: key);
  final Function() onRestart;
  final QuizGameParam multipleChoice;
  final QuizJumbleGameParam jumble;
  final Countdown countdown;

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

  Widget _rowOfButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AppIconButton(
          onTap: onRestart, 
          iconPath: AppIcons.retry, 
          height: 50, 
          width: 50, 
          backgroundColor: AppColors.primary
        ),
        AppIconButton(
          onTap: (){Navigator.of(context).popUntil(ModalRoute.withName("/start-select"));}, 
          iconPath: AppIcons.viewResult, 
          height: 50, 
          width: 50, 
          backgroundColor: AppColors.primary
        ),
        AppIconButton(
          onTap: (){Navigator.of(context).popUntil(ModalRoute.withName("/start-select"));}, 
          iconPath: AppIcons.reminderSmall, 
          height: 50, 
          width: 50, 
          backgroundColor: AppColors.primary
        ),
        AppIconButton(
          onTap: (){Navigator.of(context).popUntil(ModalRoute.withName("/start-select"));}, 
          iconPath: AppIcons.exit, 
          height: 50, 
          width: 50, 
          backgroundColor: AppColors.wrong
        )
      ],
      )
    );
  }

  Widget _build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Container(
        width: size.width*0.75,
        height: size.height*0.60,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1
          ),
          color: AppColors.primary
        ),
        child: Padding(
          padding: EdgeInsets.all(6),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1
              )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(flex: 2, child: Center(child: Text("やった!", style: TextStyle(fontSize: 36)))),
                Expanded(
                  flex: 8, 
                  child: _DetailWidget(
                    jumble: jumble,
                    multipleChoice: multipleChoice, 
                    countdown: countdown,
                  )
                ),
                Flexible(flex: 2, child: _rowOfButtons(context))
              ]
            )
          )
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _build(context);
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

class _DetailWidget extends StatelessWidget {

  final QuizGameParam multipleChoice;
  final QuizJumbleGameParam jumble;
  final Countdown countdown;

  const _DetailWidget({Key? key, required this.countdown, required this.multipleChoice, required this.jumble}) : super(key: key);

  String humanize(Duration duration) {
    var seconds = duration.inSeconds;

    var minutes = (seconds/60).floor();
    var remaining = seconds % 60;
    return "${minutes > 0 ?  minutes.toString() + " minutes " : ""}$remaining seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: new TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
            children: <TextSpan>[
              TextSpan(
                text: "100",
                style: TextStyle(
                  fontSize: 70,
                  color: Colors.amber
                  
                ),
              ),
              TextSpan(text: 'pts', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Text(humanize(countdown.elapsed())),

        SizedBox(
          width: 200,
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _GameScoreWidget(
              game: "Multiple Choice", 
              correct: multipleChoice.result.correct,
              miss: multipleChoice.result.miss,
            ),
            _GameScoreWidget(
              game: "Jumble", 
              correct: jumble.result.correct,
              miss: jumble.result.miss,
              hits: jumble.result.hits
            ),
          ],
        )
        )
      ],
    );
  }
}

class _GameScoreWidget extends StatelessWidget {
  final String game;
  final int correct;
  final int miss;
  int? hits;

  _GameScoreWidget({Key? key, required this.game, required this.correct, required this.miss, this.hits}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Text(game),
        SizedBox( 
          width: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                AppIcons.check,
                height: 25,
                width: 25,
              ),
              Text(correct.toString())
            ],
          )
        ),
        hits == null ? SizedBox() :
        SizedBox(
          width: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                AppIcons.yes,
                height: 25,
                width: 25,
              ),
              Text(hits!.toString())
            ],
          )
        )
        ,
        SizedBox(
          width: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                AppIcons.wrong,
                height: 25,
                width: 25,
              ),
              Text(miss.toString())
            ],
          )
        )
      ]
    );
  }

}