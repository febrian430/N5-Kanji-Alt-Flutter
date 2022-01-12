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
  final Widget footerWhenOver;

  final Function() onPause;
  final Function() onContinue;
  final Function() onRestart;

  final GuideDialog? guide;
  Function()? onGuideOpen;

  final bool isOver;


  QuizScreen({Key? key, required this.title, required this.japanese, required this.game, required this.onPause, required this.onRestart, required this.onContinue, this.guide, this.onGuideOpen, required this.isOver, required this.footerWhenOver, }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QuizScreenState();

}

class _QuizScreenState extends State<QuizScreen> {

  bool isPaused = false;

  Widget buildConfirmationDialog(BuildContext context) {
    return ConfirmationDialog(
      onConfirm: (){
        Navigator.of(context, rootNavigator: true).popUntil(ModalRoute.withName("/start-select"));
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

  Widget _getFooter(BuildContext context) {    
    if(widget.isOver) {
      return widget.footerWhenOver;
    } else if(widget.guide == null) {
      return SizedBox();
    } else {
      return PauseButton(
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
        withChart: false,
      );
    }
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
            topRight: _guideButton(context)
          ), 
          footer: _getFooter(context),
          child: widget.game,
          horizontalPadding: false,
          topPadding: false,
          bottomPadding: false,
        ),
      )
    );
  }
}