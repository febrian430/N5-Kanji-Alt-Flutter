import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';

class ChapterSelect extends StatelessWidget {
  const ChapterSelect({Key? key}) : super(key: key);

  static const route = '/chapter-select';
  static const List<int> chapters = [1,2,3,4,5,6,7,8]; 

  @override
  Widget build(BuildContext context) {
    PracticeGameArguments param = ModalRoute.of(context)!.settings.arguments as PracticeGameArguments;

    return Scaffold(
      body: Center( 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: chapters.map((chapter) {
            return GestureDetector(
              onTap: () {
                param.chapter = chapter;
                Navigator.pushReplacementNamed(context, param.selectedGame, arguments: param);
              },
              child: Container(
                height: 50,
                width: 100  ,
                decoration: BoxDecoration(
                  color: Colors.lightBlue
                ),
                child: Center(
                  child: Text(
                    chapter.toString()
                  )
                ),
              ),
            );
          }).toList(),
        ),
      )
    );
  }
}