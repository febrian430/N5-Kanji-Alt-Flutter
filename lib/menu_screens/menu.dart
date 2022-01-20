import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/audio_repository/audio.dart';
import 'package:kanji_memory_hint/color_hex.dart';
import 'package:kanji_memory_hint/components/backgrounds/menu_background.dart';
import 'package:kanji_memory_hint/components/buttons/back_button.dart';
import 'package:kanji_memory_hint/components/header.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/menu_screens/screen_layout.dart';
import 'package:kanji_memory_hint/theme.dart';

class Menu extends StatelessWidget {

  final String title;
  final String japanese;
  final Widget child;
  final Widget? topRight;
  final bool withBottomPadding;

  const Menu({
    Key? key, 
      required this.title, 
      required this.japanese, 
      required this.child, 
      this.topRight,
      this.withBottomPadding = true
    }) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    AudioManager.playMenu();
    return MenuBackground(
      child: ScreenLayout(
        header: AppHeader(
          title: title,
          japanese: japanese,
          withBack: true,
          topRight: topRight,
        ), 
        footer: withBottomPadding ? EmptyWidget : null, 
        child: child,
        bottomPadding: withBottomPadding,
      )
    );
  }
}