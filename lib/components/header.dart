import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/back_button.dart';
import 'package:kanji_memory_hint/components/dialogs/guide.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/const.dart';
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
      height: 40,
      // aspectRatio: 1,
      width: 40,
      child: TextButton(
      onPressed: () {
        onOpen();
        showGuideDialog(context);
      },
      child: Image.asset(
        AppIcons.tutorial,
        height: 25,
        width: 25,
        fit: BoxFit.fill,
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        side: BorderSide.none
      ),
      
      )
    );  
  }

}

class AppHeader extends StatelessWidget {
  final String title;
  final String japanese;
  Color? color;
  String? icon;
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
    this.topLeft,
    this.icon
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
        // mainAxisAlignment: MainAxisAlignment.,
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
                // Flexible(
                  // flex: 2,
                  // child: icon != null ? Image.asset(icon!) : EmptyWidget
                  // child: SizedBox()
                  // child: Image.asset(AppIcons.mixmatch)
                // ),
                Flexible(
                  flex: 2, 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: color
                          ),
                        )
                      ),
                      Center(
                        child: Text(
                          japanese,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: color
                          ),
                        )
                      ),
                    ],
                  ),
                )
              ]
            ) 
          ),
          EmptyFlex(flex: 1),
          Flexible(
            flex: 4,
            child: topRight == null ? SizedBox() : topRight!
          ) 
        ],
      )    
    );
  }

  
}