import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/select_button.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/menu_screens/game_menu.dart';
import 'package:kanji_memory_hint/menu_screens/menu.dart';
import 'package:kanji_memory_hint/route_param.dart';

class ChapterSelect extends StatelessWidget {
  ChapterSelect({Key? key}) : super(key: key);

  static const route = '/chapter-select';
  static const List<int> chapters = [1,2,3,4,5,6,7,8]; 
  late PracticeGameArguments param;

  Widget buildTiles(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Center(
          child: buildPerRow(context, index+1)
        );
      }),
    );
  }

  Widget buildPerRow(BuildContext context, int row) {
    int left = (row-1)*2;

    return  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildTile(context, chapters[left], param),
        buildTile(context, chapters[left+1], param)
      ],
    );
  }

  Widget buildTile(BuildContext context, int chapter, PracticeGameArguments param){
    final width = MediaQuery.of(context).size.width;
    return SelectButton(
      width: width *.35,
      onTap: () {
        param.chapter = chapter;
        Navigator.pushNamed(context, param.selectedGame, arguments: param);
      },
      title: 'Topic ${chapter.toString()}'
    );
  }

  @override
  Widget build(BuildContext context) {
    param = ModalRoute.of(context)!.settings.arguments as PracticeGameArguments;
    final size = MediaQuery.of(context).size;

    Widget screen = buildTiles(context);

    // Widget screen3 = Container(
    //   width: size.width*.85 ,
    //   child: GridView.builder(
    //         physics: NeverScrollableScrollPhysics(),
    //         shrinkWrap: true,
    //         itemCount: chapters.length,
    //         scrollDirection: Axis.vertical,
    //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //           childAspectRatio: 18/9,
    //           crossAxisCount: 2,
    //         ),
    //         itemBuilder: (BuildContext context, int index) {
    //           return buildTile(context, index, param);
    //         }
    //   )
    // );

    return GameMenu(
      title: "Choose Topic", 
      japanese: "トピックを選択", 
      child: screen,
      type: param.gameType,
    );
  }
}