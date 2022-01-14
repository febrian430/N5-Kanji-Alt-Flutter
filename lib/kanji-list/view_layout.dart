import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/backgrounds/menu_background.dart';
import 'package:kanji_memory_hint/components/buttons/select_button.dart';
import 'package:kanji_memory_hint/components/dialogs/kana_dialog.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/header.dart';
import 'package:kanji_memory_hint/database/kanji.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/menu_screens/screen_layout.dart';
import 'package:kanji_memory_hint/theme.dart';

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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          height: 70,
          width: 180,
          child: SelectButton(title: "Kana Chart", onTap: (){
            showDialog(context: context, builder: (context) => KanaDialog());
          },
          iconPath: AppIcons.kana,
          ), 
        ),
        // Container(
        //   width: 60,
        //   height: 60,
        //   child: FloatingActionButton(
        //   onPressed: (){
        //     showDialog(context: context, builder: (context) => KanaDialog());
        //   },
        //   child: Container(
        //     child: Text(
        //     "Kana",
        //     style: TextStyle(
        //       color: Colors.black
        //     ),
        //   ),
        //   ),
        //   shape: CircleBorder(
        //     side: BorderSide(width: 2)
        //   ),
        //   backgroundColor: AppColors.primary,
        // ),
        // ),
        horizontalPadding: false,
        topPadding: true,
        bottomPadding: false,
      ),
    );
  }
}