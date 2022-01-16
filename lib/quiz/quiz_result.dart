import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/icon_button.dart';
import 'package:kanji_memory_hint/components/dialogs/reminder.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/level_widget.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/progress_bar.dart';
import 'package:kanji_memory_hint/countdown.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/humanize.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/levelling/levels.dart';
import 'package:kanji_memory_hint/scoring/quiz/quiz.dart';
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
  const QuizResult({
    Key? key, 
    required this.multipleChoice, 
    required this.jumble, 
    required this.onRestart, 
    required this.onViewResult, 
    required this.countdown,
    required this.animate
  }) : super(key: key);
  final Function() onRestart;
  final Function() onViewResult;
  final QuizGameParam multipleChoice;
  final QuizJumbleGameParam jumble;
  final Countdown countdown;
  final bool animate;

  Widget _rowOfButtons(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: EdgeInsets.only(top: 5),
          width: constraints.maxWidth*.9,
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
                flex: 1,
                child:Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child:  AppIconButton(
                    onTap: onRestart, 
                    iconPath: AppIcons.retry, 
                    height: 50, 
                    width: 50, 
                    backgroundColor: AppColors.primary
                ),
              ),
            ),
            Flexible(
                flex: 1,
                child:Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: AppIconButton(
                    onTap: onViewResult, 
                    iconPath: AppIcons.viewResult, 
                    height: 50, 
                    width: 50, 
                    backgroundColor: AppColors.primary
                  ),
                ),
            ),
            Flexible(
                flex: 1,
                child:Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: AppIconButton(
                    onTap: (){
                      showDialog(context: context, builder: (context){
                        return ReminderDialog();
                      });
                    }, 
                    iconPath: AppIcons.reminderSmall, 
                    height: 50, 
                    width: 50, 
                    backgroundColor: AppColors.primary
                ),
              ),
            ),
            Flexible(
                flex: 1,
                child:Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: AppIconButton(
                      onTap: (){Navigator.of(context).popUntil(ModalRoute.withName("/"));}, 
                      iconPath: AppIcons.home, 
                      height: 50, 
                      width: 50, 
                      backgroundColor: AppColors.wrong
                )
              ),
            ),
          ],
        )
        );
      }
    );
  }

  Widget _build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if(animate) {
      final result = QuizScoring.evaluate(multipleChoice.result, jumble.result);
      return Center(
        child: Container(
          width: size.width*0.75,
          height: size.height*0.65,
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
                  Expanded(flex: 2, child: Center(child: Text("やった!", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)))),
                  Expanded(
                    flex: 8, 
                    child: _DetailWidget(
                      jumble: jumble,
                      multipleChoice: multipleChoice, 
                      countdown: countdown,
                      gains: result,
                      animate: animate,
                    )
                  ),
                  Flexible(flex: 2, child: _rowOfButtons(context))
                ]
              )
            )
          )
        )
      );
    } else {
      return LoadingScreen();
    }
    
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
  final GameResult gains;
  final Countdown countdown;
  final bool animate;

  const _DetailWidget({
    Key? key, 
    required this.countdown, 
    required this.multipleChoice, 
    required this.jumble, 
    required this.gains, 
    this.animate = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: RichText(
            text: TextSpan(
              style: new TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: gains.pointsGained.toString(),
                  style: TextStyle(
                    fontSize: 70,
                    color: AppColors.secondary,
                  ),
                ),
                TextSpan(text: 'pts', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              ],
            ),
          )
        ),
        
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(flex: 1, child: Image.asset(AppIcons.time, height: 20, width: 20, fit: BoxFit.contain,),),
              Flexible(flex: 3, child: Text(humanize(countdown.elapsed()))),
            ]
          )
        ),
        EmptyFlex(flex: 1),
        Expanded(
          flex: 8,
          child: Container(
          // width: 200,
            padding: EdgeInsets.only(top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EmptyFlex(flex: 1),
                Expanded(
                  flex: 5,
                  child: _GameScoreWidget(
                    game: "Multiple Choice", 
                    correct: multipleChoice.result.correct,
                    miss: multipleChoice.result.miss,
                  )
                ),
                Expanded(
                  flex: 5,
                  child: _GameScoreWidget(
                    game: "Jumble", 
                    correct: jumble.result.correct,
                    miss: jumble.result.miss,
                  )
                ),
                EmptyFlex(flex: 1),

              ],
            )
          )
        ),

        Expanded(
          flex: 8, 
          child: LayoutBuilder(
            builder:(context, constraints) { 
              return LevelWidget(
                increase: gains.expGained,
                animate: animate,
                width: constraints.maxWidth*.9,
                height: constraints.maxWidth*.1,
              );
            }
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
        Flexible(
          child: Text(
            game,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        Flexible( 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                AppIcons.check,
                height: 30,
                width: 30,
              ),
              Text(
                correct.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                ),)
            ],
          )
        ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                AppIcons.wrong,
                height: 30,
                width: 30,
              ),
              Text(
                miss.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                ),
              )
            ],
          )
        )
        // hits == null ? SizedBox() :
        // SizedBox(
        //   width: 50,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Image.asset(
        //         AppIcons.yes,
        //         height: 30,
        //         width: 30,
        //       ),
        //       Text(
        //         hits!.toString(),
        //         style: TextStyle(
        //           fontWeight: FontWeight.bold,
        //           fontSize: 18
        //         ),
        //       )
        //     ],
        //   )
        // )
        // ,
        
      ]
    );
  }

}