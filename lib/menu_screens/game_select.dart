import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/select_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/menu_screens/chapter_select.dart';
import 'package:kanji_memory_hint/menu_screens/game_menu.dart';
import 'package:kanji_memory_hint/menu_screens/menu.dart';
import 'package:kanji_memory_hint/menu_screens/mode_select.dart';
import 'package:kanji_memory_hint/mix-match/game.dart';
import 'package:kanji_memory_hint/multiple-choice/game.dart';
import 'package:kanji_memory_hint/pick-drop/game.dart';
import 'package:kanji_memory_hint/quiz/quiz.dart';
import 'package:kanji_memory_hint/route_param.dart';

class GameSelect extends StatelessWidget {

  static const route = '/game';
  @override
  Widget build(BuildContext context) {
    
    // return Scaffold( 
    //   body: SafeArea(
    //     child: 
    Widget screen = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SelectButton(
                  padding: EdgeInsets.symmetric(vertical: 5),

                  onTap: () {
                    Navigator.pushNamed(context, ModeSelect.route,
                    arguments: PracticeGameArguments(selectedGame: MixMatchGame.route, gameType: GAME_TYPE.PRACTICE));
                  },
                  title: 'Mix and Match',
                  description: "Match the Kanji with its appropriate meaning",
                  iconPath: AppIcons.mixmatch,
                ),
              ),
              Center(
                child: SelectButton(
                  // Within the `Home` widget
                  padding: EdgeInsets.symmetric(vertical: 5),

                  onTap: () {
                    // Navigate to the second screen using a named route.
                    Navigator.pushNamed(context, ModeSelect.route,
                    arguments: PracticeGameArguments(selectedGame: JumbleGame.route, gameType: GAME_TYPE.PRACTICE));
                  },
                  title: 'Jumble',
                  description: "Fill the blank spots in order with the answer",
                  iconPath: AppIcons.jumble,
                ),
              ),
              Center(
                child: SelectButton(
                  // Within the `Home` widget
                  padding: EdgeInsets.symmetric(vertical: 5),

                  onTap: () {
                    Navigator.pushNamed(context, ChapterSelect.route, 
                      arguments: PracticeGameArguments(
                        selectedGame: PickDrop.route,
                        gameType: GAME_TYPE.PRACTICE
                      ));
                  },
                  title: 'Pick and Drag',
                  description: "Hold and drag the correct kanji to the image",
                  iconPath: AppIcons.pickdrop,
                ),
              ),
            ]
          );
      return GameMenu(
        title: "Practice", 
        japanese: "練習", 
        child: screen,
        type: GAME_TYPE.PRACTICE,
      );
  }
}