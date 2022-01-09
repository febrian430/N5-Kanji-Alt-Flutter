import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/back_button.dart';
import 'package:kanji_memory_hint/components/dialogs/guide.dart';
import 'package:kanji_memory_hint/icons.dart';

class GuideDialogButton extends StatelessWidget {
  final GuideDialog guide;
  final Function() onOpen;

  const GuideDialogButton({Key? key, required this.guide, required this.onOpen}) : super(key: key);

  void showGuideDialog(BuildContext context){
    showDialog(
      context: context, 
      builder: (context){
        return guide;
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      child:TextButton(
      onPressed: () {
        onOpen();
        showGuideDialog(context);
      },
      child: Image.asset(
          AppIcons.no,
          fit: BoxFit.cover,
        ),
      ),
    );  
  }

}

class AppHeader extends StatelessWidget {
  final String title;
  final String japanese;
  GuideDialogButton? guideButton;
  bool withBack;
  
  AppHeader({
    Key? key, 
    required this.title, 
    required this.japanese, 
    this.withBack = false, 
    this.guideButton
  }) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     width: 5
      //   )
      // ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: withBack ? AppBackButton(context) : SizedBox(),
          ),
          Expanded(
            flex: 8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Text(title)),
                Center(child: Text(japanese)),
              ],
            ), 
          ),
          Expanded(
            flex: 2,
            child: guideButton == null ? SizedBox() : guideButton!
          ) 
        ],
      )    
    );
  }

  
}