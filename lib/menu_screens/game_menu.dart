import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/color_hex.dart';
import 'package:kanji_memory_hint/components/backgrounds/menu_background.dart';
import 'package:kanji_memory_hint/components/backgrounds/practice_background.dart';
import 'package:kanji_memory_hint/components/backgrounds/quiz_background.dart';
import 'package:kanji_memory_hint/components/buttons/back_button.dart';
import 'package:kanji_memory_hint/components/header.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/menu_screens/screen_layout.dart';
import 'package:kanji_memory_hint/theme.dart';

class GameMenu extends StatelessWidget {

  final String title;
  final String japanese;
  final GAME_TYPE type;
  final Widget child;
  final Widget? footer;
  final bool withBottomPadding;

  const GameMenu({
    Key? key, 
    required this.title, 
    required this.japanese, 
    required this.child, 
    required this.type,
    this.footer,
    this.withBottomPadding = false
  }) : super(key: key);

  Widget backWidget(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
        child: Container(
          height: size.height*0.09,
          width: size.height*0.16,
          child: AppBackButton(context)
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = ScreenLayout(
      header: AppHeader(
        title: title,
        japanese: japanese,
        withBack: true,
      ), 
      footer: footer, 
      child: child,
      bottomPadding: withBottomPadding,
    );
    if(type == GAME_TYPE.PRACTICE) {
      return PracticeBackground(child: screen);
    } else {
      return QuizBackground(child: screen);
    }
  }
}