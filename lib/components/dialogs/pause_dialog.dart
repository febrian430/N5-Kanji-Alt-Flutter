import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/theme.dart';

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
        child: Dialog(
          shape: const BeveledRectangleBorder(
              side: BorderSide(color: Colors.black, width: 1)
          ),
          child: Container(
            height: size.height * 0.45,
            width: size.width * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 3, 
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 12, 0, 6),
                    child: Text("Paused",
                      style: Theme.of(context).textTheme.headline6!,  
                    )
                  )
                ),
                Flexible(
                  flex: 2, 
                  child: _DialogButton(
                    title: "Continue", 
                    onPressed: () {
                      onContinue();
                      Navigator.pop(context);
                    },
                  )
                ),
                Flexible(
                  flex: 2,
                  child:  _DialogButton(
                  title: "Restart", 
                  onPressed: () {
                    Navigator.pop(context);
                    onRestart();
                  },
                  ),
                ),
                Flexible(
                  flex: 2,
                  child:  _DialogButton(
                  title: "Kana", 
                  onPressed: (){
                    showDialog(context: context, builder: showKanaDialog);
                  }),
                ),
                Flexible(
                  flex: 2,
                  child: _QuitButton(
                    title: "Quit", 
                    onPressed: (){
                      Navigator.of(context).popUntil(ModalRoute.withName('/start-select'));
                    }
                  )
                )
              ]
            ),
          )
        )
      )
    );
  }
}

class _DialogButton extends  StatelessWidget {
  
  final String title;
  final Function() onPressed;

  const _DialogButton({Key? key, required this.title, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      width: size.width*0.4,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1
        )
      ),
      child: AspectRatio(
        aspectRatio: 30/9,
        child: TextButton(
          onPressed: onPressed,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.black
              ),
            ),
          )
        )
      )
    );
  }
}

class _QuitButton extends  StatelessWidget {
  
  final String title;
  final Function() onPressed;

  const _QuitButton({Key? key, required this.title, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      width: size.width*0.4,
  
      decoration: BoxDecoration(
        border: Border.all(
          width: 2
        )
      ),
      child: AspectRatio(
        aspectRatio: 30/9,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.red
          ),
          onPressed: onPressed,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white
              ),
            ),
          )
        )
      )
    );
  }
}