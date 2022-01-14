import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/backgrounds/practice_background.dart';
import 'package:kanji_memory_hint/components/backgrounds/quiz_background.dart';
import 'package:kanji_memory_hint/components/buttons/pause_button.dart';
import 'package:kanji_memory_hint/components/dialogs/confirmation_dialog.dart';
import 'package:kanji_memory_hint/components/dialogs/guide.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/header.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/menu_screens/screen_layout.dart';

class GameScreen extends StatefulWidget {

  final String title;
  final String japanese;
  final Widget game;
  final GuideDialog guide;
  final Widget? footer;

  final Function() onPause;
  final Function() onContinue;
  final Function() onRestart;
  final Function() onGuideOpen;

  final bool prevVisible;
  final bool nextVisible;
  final Function()? onPrev;
  final Function()? onNext;


  GameScreen({Key? key, 
    required this.title, 
    required this.japanese, 
    required this.game, 
    required this.onPause, 
    required this.onRestart, 
    required this.onContinue, 
    required this.guide, 
    required this.onGuideOpen, 
    this.prevVisible = false, 
    this.nextVisible = false, 
    this.onPrev, 
    this.onNext, 
    this.footer, 
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GameScreenState();

}

class _GameScreenState extends State<GameScreen> {

  bool isPaused = false;

  Widget buildConfirmationDialog(BuildContext context) {
    return ConfirmationDialog(
      onConfirm: (){
        Navigator.of(context, rootNavigator: true).popUntil(ModalRoute.withName("/start-select",));
      },
      onCancel: (){
        Navigator.of(context, rootNavigator: true).pop(false);
      },
    );
  }

  Future<bool> showConfirmationDialog(BuildContext context) async {
    bool exit;
    exit = await showDialog(
      context: context, 
      builder: buildConfirmationDialog
    );
    return exit;
  }

  Widget _footerWithPrevNext(BuildContext context) {
    return Row(
      children: [
        widget.prevVisible ? Expanded(
          child: TextButton(
            child: Image.asset(AppIcons.prev),
            onPressed: widget.onPrev,
            style: TextButton.styleFrom(
              side: BorderSide.none,
              backgroundColor: Colors.transparent
            ),
          )
        ) : EmptyFlex(flex: 1),
        widget.footer == null ? EmptyFlex(flex: 1)
        :
        Expanded(flex: 1, child: widget.footer!),
        widget.nextVisible ? Expanded(
          child: TextButton(
            child: Image.asset(AppIcons.next),
            onPressed: widget.onNext,
            style: TextButton.styleFrom(
              side: BorderSide.none,
              backgroundColor: Colors.transparent
            ),
          )
        ) : EmptyFlex(flex: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool exit = await showConfirmationDialog(context);
        print("EXIT FROM GAME SCREEN $exit");
        return exit;
      },
      child: PracticeBackground(
        child: ScreenLayout(
          header: AppHeader(
            title: widget.title, 
            japanese: widget.japanese,
            withBack: false,
            topRight: GuideDialogButton(
              guide: widget.guide,
              onOpen: widget.onGuideOpen,
            ),
            topLeft: PauseButton(
            onPause: () {
              setState(() {
                isPaused = true;
              });
              widget.onPause();
            },
            onContinue: () {
              setState(() {
                isPaused = false;
              });
              widget.onContinue();
            },
            onRestart: widget.onRestart,
          ), 
          ), 
          footer: _footerWithPrevNext(context), 
          child: widget.game,
          horizontalPadding: false,
          topPadding: true,
        )
      )
    );
  }
}