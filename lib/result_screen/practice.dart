import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/backgrounds/menu_background.dart';
import 'package:kanji_memory_hint/components/backgrounds/practice_background.dart';
import 'package:kanji_memory_hint/components/buttons/icon_button.dart';
import 'package:kanji_memory_hint/components/dialogs/reminder.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/level_widget.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/progress_bar.dart';
import 'package:kanji_memory_hint/humanize.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth*.9,
          padding: EdgeInsets.only(top: 5),
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

  Widget _screen(BuildContext context, ResultParam param, Stopwatch stopwatch) {
    final size = MediaQuery.of(context).size;

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
                Expanded(flex: 2, child: Center(child: Text("やった!", style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold)))),
                Expanded(flex: 8, child: _DetailWidget(param: param, stopwatch: stopwatch)),
                Flexible(flex: 2, child: _rowOfButtons(context, param.onRestart))
              ]
            )
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
                  text: param.result.pointsGained.toString(),
                  style: TextStyle(
                    fontSize: 70,
                    color: AppColors.secondary
                  ),
                ),
                TextSpan(
                  text: 'pts', 
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(flex: 1, child: Image.asset(AppIcons.time, height: 20, width: 20, fit: BoxFit.contain,),),
              Flexible(
                flex: 3, 
                child: Text(
                  humanize(stopwatch.elapsed),
                )
              ),
            ]
          )
        ),
        EmptyFlex(flex: 1),
        Expanded(
          flex: 8,
          child: Column(
            children: [
              Text(
                param.game,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  // fontSize: 18
                )
              ),
              SizedBox(height: 5,),
              SizedBox(
                width: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      AppIcons.check,
                      height: 30,
                      width: 30,
                    ),
                    Text(
                      param.score.perfectRounds.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      )
                    )
                  ],
                )
              ),
              SizedBox(
                width: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      AppIcons.wrong,
                      height: 25,
                      width: 25,
                    ),
                    Text(
                      param.score.wrongAttempts.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      )
                    )
                  ],
                )
              ),
            ]
          )
        ),
    
        Expanded(
          flex: 10,
          child: LayoutBuilder(
            builder:(context, constraints) { 
              return LevelWidget(
                increase: param.result.expGained,
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