import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/backgrounds/practice_background.dart';
import 'package:kanji_memory_hint/components/backgrounds/quiz_background.dart';
import 'package:kanji_memory_hint/components/buttons/pause_button.dart';
import 'package:kanji_memory_hint/components/dialogs/confirmation_dialog.dart';
import 'package:kanji_memory_hint/components/dialogs/guide.dart';
import 'package:kanji_memory_hint/components/header.dart';
import 'package:kanji_memory_hint/menu_screens/screen_layout.dart';

class QuizScreen extends StatefulWidget {

  final String title;
  final String japanese;
  final Widget game;

  final Function() onPause;
  final Function() onContinue;
  final Function() onRestart;

  final GuideDialog? guide;
  Function()? onGuideOpen;

  final bool isQuizOver;


  QuizScreen({Key? key, required this.title, required this.japanese, required this.game, required this.onPause, required this.onRestart, required this.onContinue, this.guide, this.onGuideOpen, required this.isQuizOver, }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QuizScreenState();

}

class _QuizScreenState extends State<QuizScreen> {

  bool isPaused = false;

  Widget buildConfirmationDialog(BuildContext context) {
    return ConfirmationDialog(
      onConfirm: (){
        Navigator.of(context, rootNavigator: true).pop(true);
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

  GuideDialogButton? _guideButton(BuildContext context) {
    return widget.guide != null ? GuideDialogButton(
      guide: widget.guide!,
      onOpen: widget.onGuideOpen!,
    ) : null;
  }

  Widget _pauseButtonOrEmptyBox(BuildContext context) {
    return (widget.guide == null || widget.isQuizOver) ? SizedBox() : PauseButton(
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
      child: QuizBackground(
        child: ScreenLayout(
          header: AppHeader(
            title: widget.title, 
            japanese: widget.japanese,
            withBack: false,
            guideButton: _guideButton(context)
          ), 
          footer: _pauseButtonOrEmptyBox(context),
          child: widget.game
        )
      )
    );
  }
}