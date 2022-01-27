import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/audio_repository/audio.dart';
import 'package:kanji_memory_hint/components/backgrounds/practice_background.dart';
import 'package:kanji_memory_hint/components/backgrounds/quiz_background.dart';
import 'package:kanji_memory_hint/components/buttons/pause_button.dart';
import 'package:kanji_memory_hint/components/dialogs/confirmation_dialog.dart';
import 'package:kanji_memory_hint/components/dialogs/guide.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/header.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/menu_screens/menu.dart';
import 'package:kanji_memory_hint/menu_screens/screen_layout.dart';
import 'package:kanji_memory_hint/theme.dart';

class GameScreen extends StatefulWidget {

  final String title;
  final String japanese;
  final Widget game;
  final GuideDialog guide;
  final Widget? footer;
  final String icon;
  final bool isGameOver;

  final bool withHorizontalPadding;

  final Function() onPause;
  final Function() onContinue;
  final Function() onRestart;
  final Function() onGuideOpen;

  final bool prevVisible;
  final bool nextVisible;
  final Function()? onPrev;
  final Function()? onNext;

  final int? gameFlex;


  GameScreen({Key? key, 
    required this.title, 
    required this.japanese, 
    required this.game, 
    required this.onPause, 
    required this.onRestart, 
    required this.onContinue, 
    required this.guide, 
    required this.onGuideOpen, 
    required this.icon,
    this.prevVisible = false, 
    this.nextVisible = false, 
    this.onPrev, 
    this.onNext, 
    this.footer, 
    this.withHorizontalPadding = false,
    this.gameFlex,
    this.isGameOver = false
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GameScreenState();

}

class _GameScreenState extends State<GameScreen> {

  bool isPaused = false;

  @override
  void initState(){
    super.initState();

    AudioManager.playGame();
  }

  Widget buildConfirmationDialog(BuildContext context) {
    return ConfirmationDialog(
      onConfirm: (){
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil("/", ModalRoute.withName("/",));
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
          flex: 1,
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
        Expanded(flex: 2, child: widget.footer!),
        widget.nextVisible ? Expanded(
          flex:1,
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
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if(!widget.isGameOver) {
          bool exit = await showConfirmationDialog(context);
          print("EXIT FROM GAME SCREEN $exit");
          if(exit) {
            AudioManager.playMenu();
          }
          return exit;
        }
        Navigator.of(context).popUntil(ModalRoute.withName("/"));
        return widget.isGameOver;
      },
      child: PracticeBackground(
        child: ScreenLayout(
          header: AppHeader(
            title: widget.title, 
            japanese: widget.japanese,
            color: AppColors.white,
            withBack: false,
            topRight: GuideDialogButton(
              guide: widget.guide,
              onOpen: widget.onGuideOpen,
            ),
            icon: widget.icon,
            topLeft: !widget.isGameOver ?  PauseButton(
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
            ) : SizedBox(), 
          ), 
          footer: _footerWithPrevNext(context), 
          childFlex: widget.gameFlex,
          child: widget.game,
          horizontalPadding: widget.withHorizontalPadding,
          topPadding: true,
          // customTopPadding: size.height*.020,
        )
      )
    );
  }
}