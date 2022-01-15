import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/components/backgrounds/menu_background.dart';
import 'package:kanji_memory_hint/components/header.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/menu_screens/screen_layout.dart';

class RewardScreenLayout extends StatelessWidget {
  final Widget child;
  final Widget gold;
  const RewardScreenLayout({Key? key, required this.child, required this.gold}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuBackground(
      child: ScreenLayout(
        header: AppHeader(
          title: "Reward", 
          japanese: "褒美",
          topRight: gold,
          withBack: true,
        ),
        child: child,
        footer: null,
        horizontalPadding: false,
        bottomPadding: false,
      )
    );
  }

}