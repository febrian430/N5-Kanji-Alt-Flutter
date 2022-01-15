import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/progress_bar.dart';
import 'package:kanji_memory_hint/levelling/levels.dart';
import 'package:kanji_memory_hint/theme.dart';

class LevelWidget extends StatefulWidget {
  const LevelWidget({
    Key? key, 
    required this.increase
  }) : super(key: key);

  final int increase;

  @override
  State<StatefulWidget> createState() => _LevelWidgetState();

}

class _LevelWidgetState extends State<LevelWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Levels.current(),
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if(snapshot.hasData){  
          final level = snapshot.data![0];
          final remaining = snapshot.data![1];
          final nextLevel = Levels.next(level);
          final nextNextLevel = Levels.next(level+1);
          return LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth*.8,
                height: constraints.maxWidth*.05,
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
                    Expanded(
                      flex: 2,
                      child: ProgressBar(
                        current: remaining, 
                        gain: widget.increase, 
                        upperbound: nextLevel ?? remaining, 
                        nextUpperbound: nextNextLevel, 
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
            }
          );
        } else {
          return LoadingScreen();
        }
      }
    );
  }

}