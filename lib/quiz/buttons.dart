import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/submit_button.dart';
import 'package:kanji_memory_hint/icons.dart';

class GameButtons extends StatelessWidget {
  final bool buttonVisible;
  final String title;
  final int count;
  final int current;
  final Function() onButtonClick;
  final Function() onPrev;
  final Function() onNext;

  GameButtons({Key? key, 
    required this.buttonVisible, 
    required this.onPrev, 
    required this.onNext, 
    required this.onButtonClick,
    required this.title,
    required this.count,
    required this.current
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        current != 0 ? Expanded(
          flex: 1,
          child: TextButton(
            onPressed: onPrev,
            child: Image.asset(AppIcons.prev),
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: BorderSide.none
            ),
          )
        )
        :
        EmptyFlex(flex: 1),

        // EmptyFlex(flex: 1),
        Expanded(
          flex: 2,
          child: VisibleButton(
              visible: buttonVisible, 
              onTap: onButtonClick,
              title: title,
            )
        ),

        // EmptyFlex(flex: 1),
        current != count-1 ? Expanded(
          flex: 1,
          child: TextButton(
            onPressed: onNext,
            child: Image.asset(AppIcons.next),
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: BorderSide.none
            ),
          )
        )
        :
        EmptyFlex(flex: 1),
      ]
    );
  }

}