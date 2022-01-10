import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/backgrounds/menu_background.dart';
import 'package:kanji_memory_hint/components/backgrounds/practice_background.dart';
import 'package:kanji_memory_hint/components/buttons/icon_button.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/main.dart';
import 'package:kanji_memory_hint/menu_screens/menu.dart';
import 'package:kanji_memory_hint/route_param.dart';
import 'package:kanji_memory_hint/theme.dart';

class ResultScreen extends StatelessWidget{
  // ResultScreen({required this.wrongCount, required this.decreaseFactor}){
  //   points = 1000 - decreaseFactor*wrongCount;
  // }

  ResultScreen({Key? key}) : super(key: key);

  static const route = "/result";
  
  // final int wrongCount = 0;
  // final int decreaseFactor = 0;
  // late int points = 0;

  Widget _rowOfButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AppIconButton(
          onTap: (){}, 
          iconPath: AppIcons.resume, 
          height: 50, 
          width: 50, 
          backgroundColor: AppColors.primary
        ),
        AppIconButton(
          onTap: (){Navigator.of(context).popUntil(ModalRoute.withName("/game"));}, 
          iconPath: AppIcons.viewResult, 
          height: 50, 
          width: 50, 
          backgroundColor: AppColors.primary
        ),
        AppIconButton(
          onTap: (){Navigator.of(context).popUntil(ModalRoute.withName("/game"));}, 
          iconPath: AppIcons.reminderSmall, 
          height: 50, 
          width: 50, 
          backgroundColor: AppColors.primary
        ),
        AppIconButton(
          onTap: (){Navigator.of(context).popUntil(ModalRoute.withName("/game"));}, 
          iconPath: AppIcons.exit, 
          height: 50, 
          width: 50, 
          backgroundColor: AppColors.wrong
        )
      ],
      )
    );
  }

  Widget _screen(BuildContext context, ResultParam param, Stopwatch stopwatch) {
    final size = MediaQuery.of(context).size;

    return Container(
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
          Expanded(flex: 2, child: Center(child: Text("CONGRATS", style: TextStyle(fontSize: 36)))),
          Expanded(flex: 6, child: _DetailWidget(param: param, stopwatch: stopwatch)),
          Flexible(flex: 1, child: _rowOfButtons(context))
        ]
          )
          )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    var param = ModalRoute.of(context)!.settings.arguments as ResultParam;
    var stopwatch = param.stopwatch;
    stopwatch.stop();
    final screen = _screen(context, param, stopwatch);

    return Menu(title: "Result", japanese: "結果", child: screen);
  }
}

class _DetailWidget extends StatelessWidget {

  final ResultParam param;
  final Stopwatch stopwatch;

  const _DetailWidget({Key? key, required this.param, required this.stopwatch}) : super(key: key);

  String humanize(Stopwatch stopwatch) {
    var elapsed = stopwatch.elapsed;
    var seconds = elapsed.inSeconds;

    var minutes = (seconds/60).floor();
    var remaining = seconds % 60;
    return "${minutes > 0 ?  minutes.toString() + " min" : ""}$remaining seconds";
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
                text: param.result.pointsGained.toString(),
                style: TextStyle(
                  fontSize: 70,
                  color: Colors.amber
                  
                ),
              ),
              TextSpan(text: 'pts', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Text(humanize(stopwatch)),
        Text(param.game),
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
              Text(param.score.perfectRounds.toString())
            ],
          )
        ),
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
              Text(param.score.wrongAttempts.toString())
            ],
          )
        )
      ],
    );
  }

}