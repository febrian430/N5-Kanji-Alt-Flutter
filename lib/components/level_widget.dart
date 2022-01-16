import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/progress_bar.dart';
import 'package:kanji_memory_hint/levelling/levels.dart';
import 'package:kanji_memory_hint/theme.dart';

class LevelWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final bool animate;
  
  const LevelWidget({
    Key? key, 
    required this.increase, 
    this.width, 
    this.height,
    this.animate = true
  }) : super(key: key);

  final int increase;

  @override
  State<StatefulWidget> createState() => _LevelWidgetState();

}

class _LevelWidgetState extends State<LevelWidget> {
  int? current;

  @override
  Widget build(BuildContext context) {
    if(widget.animate) {
      return FutureBuilder(
        future: Levels.current(),
        builder: (context, AsyncSnapshot<List<int>> snapshot) {
          if(snapshot.hasData){  
            final level = snapshot.data![0];
            final remaining = snapshot.data![1];
            final nextLevel = Levels.next(level);
            final nextNextLevel = Levels.next(level+1);
            // return LayoutBuilder(
              // builder: (context, constraints) {
            Widget levelUpWidget = SizedBox();
            if(nextLevel == null) {
              levelUpWidget = Text("Max Level", textAlign: TextAlign.center,);
            } else if((widget.increase + remaining) >= nextLevel) {
              levelUpWidget = Text("Level up!", textAlign: TextAlign.center,);
            } 
            return Container(
              width: widget.width,
              height: widget.height,
              padding: EdgeInsets.fromLTRB(
                10,
                10,
                10,
                0
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                border: Border.all(width: 2)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2, 
                    child: Text(
                      "Level "+ level.toString(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Row(
                      children: [
                        EmptyFlex(flex: 1),
                        Flexible(flex: 1, child: levelUpWidget),
                        EmptyFlex(flex: 1)
                      ]
                    )
                  ),
                  Expanded(
                    flex: 3,
                    child: ProgressBar(
                      current: remaining, 
                      gain: widget.increase, 
                      upperbound: nextLevel ?? remaining, 
                      nextUpperbound: nextNextLevel, 
                      animate: widget.animate,
                      onLevelup: (){
                        String msg = "You are now level $nextLevel";
                        if(nextNextLevel == null) {
                          msg = "You reached max level";
                        }
                        final snackbar = SnackBar(
                          content: Text(msg),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    }),
                  )
                ]
              )
            );
          } else {
            return LoadingScreen();
          }
        }
      );
      } else {
        return LoadingScreen();
      }
  }

}