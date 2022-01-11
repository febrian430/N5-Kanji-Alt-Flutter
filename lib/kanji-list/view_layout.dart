import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/components/backgrounds/menu_background.dart';
import 'package:kanji_memory_hint/components/header.dart';
import 'package:kanji_memory_hint/database/kanji.dart';
import 'package:kanji_memory_hint/menu_screens/screen_layout.dart';

class KanjiLayout extends StatelessWidget {
  final int topic;
  final Widget child;

  const KanjiLayout({Key? key, required this.topic, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MenuBackground(
      child: ScreenLayout(
        header: AppHeader(title: "Topic $topic", japanese: "トピック $topic", withBack: true,),
        child: child,
        footer: SizedBox(),
        horizontalPadding: false,
        verticalPadding: false,
      ),
    );
  }
}