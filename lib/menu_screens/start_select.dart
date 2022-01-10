import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/select_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/menu_screens/chapter_select.dart';
import 'package:kanji_memory_hint/menu_screens/game_select.dart';
import 'package:kanji_memory_hint/menu_screens/menu.dart';
import 'package:kanji_memory_hint/menu_screens/mode_select.dart';
import 'package:kanji_memory_hint/quiz/quiz.dart';
import 'package:kanji_memory_hint/route_param.dart';

class StartSelect extends StatelessWidget {

  static const route = '/start-select';
  @override
  Widget build(BuildContext context) {
    Widget screen = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SelectButton(
                  title: "Practice", 
                  padding: EdgeInsets.symmetric(vertical: 10),
                  description: "Train your skills with games such as Mix & Match, Jumble, and Pick & Drop",
                  onTap: (){
                    Navigator.pushNamed(context, GameSelect.route);
                  },
                  iconPath: AppIcons.practice,
                )
              ),
              Center(
                child: SelectButton(
                  title: "Quiz",
                  padding: EdgeInsets.symmetric(vertical: 10),

                  onTap: (){
                    Navigator.pushNamed(context, ChapterSelect.route, 
                      arguments: PracticeGameArguments(selectedGame: Quiz.route));
                  },
                  description: "Feeling ready? Test your skills and earn points",
                  iconPath: AppIcons.quest,
                ),
              ),
            ]
          );
    
    return Menu(title: "Start", japanese: "スタート", child: screen);
   
  }
}