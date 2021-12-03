import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/menu_screens/chapter_select.dart';

class ModeSelect extends StatelessWidget {
  const ModeSelect({Key? key}) : super(key: key);

  static const route = '/mode-select';
  static const List<int> chapters = [1,2,3,4,5,6,7,8]; 


  
  @override
  Widget build(BuildContext context) {

    PracticeGameArguments param = ModalRoute.of(context)!.settings.arguments as PracticeGameArguments;

    return Scaffold(
      body: Center( 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                param.mode = GAME_MODE.imageMeaning;
                Navigator.pushReplacementNamed(context, ChapterSelect.route, arguments: param);
              },
              child: Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.lightBlue
                ),
                child: const Center(
                  child: Text(
                    "Image Meaning"
                  ),
                )
              )
            ),
            SizedBox(height: 100),
            GestureDetector(
              onTap: () {
                param.mode = GAME_MODE.reading;
                Navigator.pushReplacementNamed(context, ChapterSelect.route, arguments: param);
              },
              child: Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.lightBlue
                ),
                child: const Center(
                  child: Text(
                    "Reading"
                  ),
                )
              )
            ),
          ]
        ),
      )
    );
  }
}