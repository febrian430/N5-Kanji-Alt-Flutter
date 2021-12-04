import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/menu_screens/mode_select.dart';
import 'package:kanji_memory_hint/mix-match/game.dart';
import 'package:kanji_memory_hint/multiple-choice/game.dart';
import 'package:kanji_memory_hint/pick-drop/game.dart';
import 'package:kanji_memory_hint/route_param.dart';

class GameSelect extends StatelessWidget {

  static const route = '/game';
  @override
  Widget build(BuildContext context) {
    
    return Scaffold( 
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: ElevatedButton(
                  // Within the `Home` widget
                  onPressed: () {
                    // Navigate to the second screen using a named route.
                    Navigator.pushNamed(context, ModeSelect.route, 
                    arguments: PracticeGameArguments(
                      selectedGame: MultipleChoiceGame.route,
                    ));
                  },
                  child: const Text('Multiple Choice'),
                ),
              ),
              Center(
                child: ElevatedButton(
                  // Within the `Home` widget
                  onPressed: () {
                    // Navigate to the second screen using a named route.
                    Navigator.pushNamed(context, ModeSelect.route,
                    arguments: PracticeGameArguments(selectedGame: PickDrop.route));
                  },
                  child: const Text('Pick and Drop'),
                ),
              ),
              Center(
                child: ElevatedButton(
                  // Within the `Home` widget
                  onPressed: () {
                    // Navigate to the second screen using a named route.
                    Navigator.pushNamed(context, ModeSelect.route,
                    arguments: PracticeGameArguments(selectedGame: MixMatchGame.route));
                  },
                  child: const Text('Mix and Match'),
                ),
              ),
              Center(
                child: ElevatedButton(
                  // Within the `Home` widget
                  onPressed: () {
                    // Navigate to the second screen using a named route.
                    Navigator.pushNamed(context, ModeSelect.route,
                    arguments: PracticeGameArguments(selectedGame: JumbleGame.route));
                  },
                  child: const Text('Jumble'),
                ),
              ),
            ]
          )
      )
    );
  }
}