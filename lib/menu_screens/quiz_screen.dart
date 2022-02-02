import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/audio_repository/audio.dart';
import 'package:kanji_memory_hint/components/backgrounds/quiz_background.dart';
import 'package:kanji_memory_hint/components/buttons/pause_button.dart';
import 'package:kanji_memory_hint/components/dialogs/confirmation_dialog.dart';
import 'package:kanji_memory_hint/components/dialogs/guide.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/header.dart';
import 'package:kanji_memory_hint/countdown.dart';
import 'package:kanji_memory_hint/menu_screens/screen_layout.dart';
import 'package:kanji_memory_hint/theme.dart';

class QuizScreen extends StatefulWidget {

  final String title;
  final String japanese;
  final Widget game;
  final Widget footerWhenOver;
  final Widget? footer;
  final CountdownWidget countdownWidget;

  final Function() onPause;
  final Function() onContinue;
  final Function() onRestart;

  final GuideDialog? guide;
  Function()? onGuideOpen;

  final bool isOver;


  QuizScreen({
    Key? key, 
    required this.title, 
    required this.japanese, 
    required this.game, 
    required this.onPause, 
    required this.onRestart, 
    required this.onContinue, 
    this.guide, 
    this.onGuideOpen, 
    required this.isOver, 
    required this.footerWhenOver, 
    this.footer, 
    required this.countdownWidget
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QuizScreenState();

}

class _QuizScreenState extends State<QuizScreen> {

  bool isPaused = false;

  @override
  void initState(){
    super.initState();
    AudioManager.music.game();
  }

  Widget buildConfirmationDialog(BuildContext context) {
    return ConfirmationDialog(
      onConfirm: (){
        // AudioManager.playMenu();
        // Navigator.of(context, rootNavigator: true).popUntil(ModalRoute.withName("/"));
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
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

  Widget? _getFooter(BuildContext context) {    
    if(widget.isOver) {
      return widget.footerWhenOver;
    } else if(widget.footer != null){
      return widget.footer!; 
    }else {
      return null;
    }
  }

  Widget _getTopLeft(BuildContext context){
    if(widget.isOver) {
      return SizedBox();
     } else { 
      return Row( 
        children: [
          EmptyFlex(flex: 1),
          Expanded(
            flex: 2, 
            child: PauseButton(
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
            )
          ),
          
          Expanded(
            flex: 2,
            child: widget.countdownWidget
          )
        ]
      );
     }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if(!widget.isOver){
          bool exit = await showConfirmationDialog(context);
          if(exit) {
            AudioManager.music.menu();
          }
          return exit;
        }
        Navigator.of(context).popUntil(ModalRoute.withName("/"));
        AudioManager.music.menu();

        return widget.isOver;
      },
      child: QuizBackground(
        child: ScreenLayout(
          header: AppHeader(
            title: widget.title, 
            japanese: widget.japanese,
            color: AppColors.white,
            withBack: false,
            topLeft: _getTopLeft(context),
            topRight: _guideButton(context)
          ), 
          footer: _getFooter(context),
          child: widget.game,
          horizontalPadding: false,
          topPadding: true,
          bottomPadding: !widget.isOver,
          customBottomPadding: !widget.isOver ? size.height*.032 : null,

        ),
      )
    );
  }
}