import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/back_button.dart';
import 'package:kanji_memory_hint/components/header.dart';
import 'package:kanji_memory_hint/menu_screens/screen_layout.dart';

class Menu extends StatelessWidget {

  final String title;
  final String japanese;
  final Widget child;

  const Menu({Key? key, required this.title, required this.japanese, required this.child}) : super(key: key);

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
    return ScreenLayout(
      header: AppHeader(
        title: title,
        japanese: japanese,
      ), 
      footer: backWidget(context), 
      child: child
    );
  }
}