import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/header.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/menu_screens/screen_layout.dart';

class GameScreen extends StatefulWidget {

  final String title;
  final String japanese;
  final Widget game;

  final Function() onPause;
  final Function() onContinue;
  final Function() onRestart;

  const GameScreen({Key? key, required this.title, required this.japanese, required this.game, required this.onPause, required this.onRestart, required this.onContinue}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GameScreenState();

}

class _GameScreenState extends State<GameScreen> {

  bool isPaused = false;

  Widget buildDialog(BuildContext context) {
    return PauseDialog(onRestart: widget.onRestart, onContinue: widget.onContinue,);
  }

  Widget pauseButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isPaused = true;
        });
        showDialog(
          context: context, 
          builder: buildDialog,
          // barrierDismissible: false
        );
        widget.onPause();
      },
      style: Theme.of(context).textButtonTheme.style,
      child: Container(
        child: Image.asset(
          APP_IMAGE_FOLDER+'pause.png',
          height: 25,
          width: 25,
          // fit: BoxFit.scaleDown,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2
          )
        ),
        height: size.width*0.075,
        width: size.width*0.075,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenLayout(
      header: AppHeader(
        title: widget.title, 
        japanese: widget.japanese
      ), 
      footer: pauseButton(context), 
      child: widget.game
    );
  }
}

class PauseDialog extends StatelessWidget {
  
  final Function() onContinue;
  final Function() onRestart;

  const PauseDialog({Key? key, required this.onContinue, required this.onRestart}) : super(key: key);

  Dialog showKanaDialog(BuildContext context) {
      final size = MediaQuery.of(context).size;

      return Dialog(
        child: Container(
          child: Text("Kana image here"),
          height: size.height * 0.75,
          width: size.width * 0.75,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        onContinue();
        return true;
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: SimpleDialog(
          title: Center(child: Text("Paused")),
          elevation: 1,
          shape: const BeveledRectangleBorder(
              side: BorderSide(color: Colors.black, width: 3)
          ),
          children: [
            SimpleDialogOption(
              child: Center(child: Text("Continue")), 
              onPressed: () {
                onContinue();
                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(child: Center(child: Text("Restart")), onPressed: onRestart,),
            SimpleDialogOption(
              child: Center(child: Text("Kana")), 
              onPressed: (){
                showDialog(context: context, builder: showKanaDialog);
              }
            ),
            SimpleDialogOption(
              child: const Center(child: Text("Quit")), 
              onPressed: (){
                Navigator.of(context).popUntil(ModalRoute.withName('/start-select'));
              })
          ],
        )
      )
    );
  }
}