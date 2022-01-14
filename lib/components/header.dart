import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/back_button.dart';
import 'package:kanji_memory_hint/components/dialogs/guide.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/theme.dart';

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
    final size = MediaQuery.of(context).size;
 
    return Container(
      height: 30,
      width: 30,
      child: 
      TextButton(
      onPressed: () {
        onOpen();
        showGuideDialog(context);
      },
      style: TextButton.styleFrom(
        shape: CircleBorder(
          side: BorderSide(width: 1)
        )
      ),
      child:
        Text(
        "?",
        style: TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.bold
        ),
      )
      )
    );  
  }

}

class AppHeader extends StatelessWidget {
  final String title;
  final String japanese;
  Color? color;
  Widget? topRight;
  Widget? topLeft;
  bool withBack;
  
  AppHeader({
    Key? key, 
    required this.title, 
    required this.japanese, 
    this.color = Colors.black,
    this.withBack = false, 
    this.topRight,
    this.topLeft
  }) : super(key: key);

  Widget _topLeft(BuildContext context) {
    if(withBack){
      return AppBackButton(context);
    } else if(topLeft != null) {
      return topLeft!;
    } else {
      return SizedBox();
    }
  }

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
            flex: 5,
            child: _topLeft(context),
          ),
          Expanded(
            flex: 8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color
                    ),
                  )
                ),
                Center(
                  child: Text(
                    japanese,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color
                    ),
                  )
                ),
              ],
            ), 
          ),
          Flexible(
            flex: 5,
            child: topRight == null ? SizedBox() : topRight!
          ) 
        ],
      )    
    );
  }

  
}