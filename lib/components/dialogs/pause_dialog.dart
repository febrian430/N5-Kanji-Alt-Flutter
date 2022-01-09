import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/icons.dart';
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
            width: size.width * 0.45,
            padding: EdgeInsets.all(6),
            child: Container(
              height: size.height*0.40,
              width: size.width*0.40,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1
                )
              ),
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
                  flex: 8,
                  child: SizedBox(
                    width: size.width*0.48,
                    child: GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,

                    ),
                    children: [
                      _DialogButton(
                          icon: AppIcons.resume, 
                          onPressed: () {
                            onContinue();
                            Navigator.pop(context);
                          },
                        ),
                      
                      _DialogButton(
                        icon: AppIcons.resume, 
                        onPressed: () {
                          Navigator.pop(context);
                          onRestart();
                        },
                        ),
                      _DialogButton(
                        icon: AppIcons.kana, 
                        onPressed: (){
                          showDialog(context: context, builder: showKanaDialog);
                        }),
                      _QuitButton(
                          icon: AppIcons.exit, 
                          onPressed: (){
                            Navigator.of(context).popUntil(ModalRoute.withName('/start-select'));
                          }
                        )
                    ],
                  ),
                  )
                )
              ]
              )
            ),
          )
        )
      )
    );
  }
}

class _DialogButton extends  StatelessWidget {
  
  final String icon;
  final Function() onPressed;

  const _DialogButton({Key? key, required this.icon, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
      width: size.width*0.4,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1
        )
      ),
        child: TextButton(
          onPressed: onPressed,
          child: Container(
            alignment: Alignment.center,
            child: Image.asset(
              icon,
              height: 50,
              width: 50,
            )
          )
          )
        )
    );
  }
}

class _QuitButton extends  StatelessWidget {
  
  final String icon;
  final Function() onPressed;

  const _QuitButton({Key? key, required this.icon, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
      width: size.width*0.4,
  
      decoration: BoxDecoration(
        border: Border.all(
          width: 2
        )
      ),
      child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: AppColors.wrong
          ),
          onPressed: onPressed,
          child: Container(
            alignment: Alignment.center,
            child: Image.asset(
              icon,
              height: 50,
              width: 50,
            )
          )
        )
      )
    );
  }
}