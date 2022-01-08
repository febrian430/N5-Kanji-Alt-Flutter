import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/select_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/menu_screens/chapter_select.dart';
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
              // Center(
              //   child: ElevatedButton(
              //     // Within the `Home` widget
              //     onPressed: () {
              //       // Navigate to the second screen using a named route.
              //       Navigator.pushNamed(context, ModeSelect.route, 
              //       arguments: PracticeGameArguments(
              //         selectedGame: MultipleChoiceGame.route,
              //       ));
              //     },
              //     child: const Text('Multiple Choice'),
              //   ),
              // ),
              Center(
                child: SelectButton(
                  onTap: () {
                    Navigator.pushNamed(context, ModeSelect.route,
                    arguments: PracticeGameArguments(selectedGame: MixMatchGame.route));
                  },
                  title: 'Mix and Match',
                  description: "Match the Kanji with its appropriate meaning",
                  iconPath: AppIcons.mixmatch,
                ),
              ),
              Center(
                child: SelectButton(
                  // Within the `Home` widget
                  onTap: () {
                    // Navigate to the second screen using a named route.
                    Navigator.pushNamed(context, ModeSelect.route,
                    arguments: PracticeGameArguments(selectedGame: JumbleGame.route));
                  },
                  title: 'Jumble',
                  description: "Choose the correct answer",
                  iconPath: AppIcons.jumble,
                ),
              ),
              Center(
                child: SelectButton(
                  // Within the `Home` widget
                  onTap: () {
                    Navigator.pushNamed(context, ChapterSelect.route, arguments: PracticeGameArguments(selectedGame: PickDrop.route));
                  },
                  title: 'Pick and Drag',
                  description: "Pick and Drag the correct kanji",
                  iconPath: AppIcons.pickdrop,
                ),
              ),
            ]
          );
      return Menu(title: "Choose Game", japanese: "in japanese", child: screen);
  }
}