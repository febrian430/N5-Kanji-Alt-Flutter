import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/backgrounds/menu_background.dart';
import 'package:kanji_memory_hint/components/backgrounds/practice_background.dart';
import 'package:kanji_memory_hint/components/buttons/icon_button.dart';
import 'package:kanji_memory_hint/components/dialogs/reminder.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/progress_bar.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/levelling/levels.dart';
import 'package:kanji_memory_hint/main.dart';
import 'package:kanji_memory_hint/menu_screens/menu.dart';
import 'package:kanji_memory_hint/route_param.dart';
import 'package:kanji_memory_hint/theme.dart';

class ResultScreen extends StatelessWidget{


  ResultScreen({Key? key}) : super(key: key);

  static const route = "/result";

  Widget _givePadding(BuildContext context, Widget widget, double size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size),
      child: widget 
    );
  }

  Widget _rowOfButtons(BuildContext context, Function() onRestart) {
    return Padding(
      padding: EdgeInsets.all(6),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
            flex: 1,
            child:Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
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
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: AppIconButton(
                onTap: (){Navigator.of(context).pop();}, 
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
              padding: EdgeInsets.symmetric(horizontal: 6),
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
              padding: EdgeInsets.symmetric(horizontal: 6),
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
          Expanded(flex: 2, child: Center(child: Text("やった!", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)))),
          Expanded(flex: 6, child: _DetailWidget(param: param, stopwatch: stopwatch)),
          Flexible(flex: 2, child: _rowOfButtons(context, param.onRestart))
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
    return "${minutes > 0 ?  minutes.toString() + " min " : ""}$remaining sec";
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
                  color: AppColors.secondary
                  
                ),
              ),
              TextSpan(text: 'pts', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(flex: 1, child: Image.asset(AppIcons.time, height: 20, width: 20, fit: BoxFit.contain,),),
            Flexible(flex: 3, child: Text(humanize(stopwatch))),
          ]
        ),
        SizedBox(
          height: 25,
        ),
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
        ),
        SizedBox(
          height: 25,
        ),
        FutureBuilder(
          future: Levels.current(),
          builder: (context, AsyncSnapshot<List<int>> snapshot) {
            if(snapshot.hasData){  
              final level = snapshot.data![0];
              final remaining = snapshot.data![1];
              final nextLevel = Levels.next(level) ?? remaining;
              final nextNextLevel = Levels.next(level+1) ?? remaining;

              return Column(
                children: [
                  ProgressBar(
                    from: remaining, 
                    gain: param.result.expGained, 
                    levelupReq: nextLevel, 
                    nextLevel: nextNextLevel, 
                    onLevelup: (){
                      print("level up!");
                  }),
                ]
              );
            } else {
              return LoadingScreen();
            }
          }
        )
        
      ],
    );
  }

}