import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/icon_button.dart';
import 'package:kanji_memory_hint/components/buttons/select_button.dart';
import 'package:kanji_memory_hint/components/dialogs/chapter_select_dialog.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/kanji.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/kanji-list/kanji_menu.dart';
import 'package:kanji_memory_hint/kanji-list/parameter.dart';
import 'package:kanji_memory_hint/kanji-list/tile_alt.dart';
import 'package:kanji_memory_hint/menu_screens/game_menu.dart';
import 'package:kanji_memory_hint/menu_screens/menu.dart';
import 'package:kanji_memory_hint/route_param.dart';
import 'package:kanji_memory_hint/theme.dart';
import 'package:kanji_memory_hint/map_indexed.dart';


// class ChapterSelect extends StatelessWidget {
//   ChapterSelect({Key? key}) : super(key: key);

//   static const route = '/chapter-select';
//   static const List<int> chapters = [1,2,3,4,5,6,7,8]; 
//   late PracticeGameArguments param;

//   Widget buildTiles(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(4, (index) {
//         return Center(
//           child: buildPerRow(context, index+1)
//         );
//       }),
//     );
//   }

//   Widget buildPerRow(BuildContext context, int row) {
//     int left = (row-1)*2;

//     return  Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         buildTile(context, chapters[left], param),
//         buildTile(context, chapters[left+1], param)
//       ],
//     );
//   }

//   Widget buildTile(BuildContext context, int chapter, PracticeGameArguments param){
//     final width = MediaQuery.of(context).size.width;
//     return SelectButton(
//       width: width *.35,
//       onTap: () {
//         param.chapter = chapter;
//         Navigator.pushNamed(context, param.selectedGame, arguments: param);
//       },
//       title: 'Topic ${chapter.toString()}'
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     param = ModalRoute.of(context)!.settings.arguments as PracticeGameArguments;
//     final size = MediaQuery.of(context).size;

//     Widget screen = buildTiles(context);

//     return GameMenu(
//       title: "Choose Topic", 
//       japanese: "トピックを選択", 
//       child: screen,
//       type: param.gameType,
//     );
//   }
// }

class ChapterSelect extends StatelessWidget {
  ChapterSelect({Key? key}) : super(key: key);

  static const route = '/chapter-select';
  // static const List<int> chapters = [1,2,3]; 
  static const List<int> chapters = USE_CHAPTERS; 
  late PracticeGameArguments param;

  Widget _build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return  ListView(
        padding: EdgeInsets.only(top: size.height*0),
        children: chapters.map((chapter){
            return Padding(
              padding: EdgeInsets.symmetric(vertical: size.height*.0062),
              child: Row(
                children: [
                  EmptyFlex(flex: 3),
                  Flexible(
                    flex: 8,
                    child: SelectButton(
                    title: 'Topic $chapter', 
                    onTap: (){
                      showDialog(
                        context: context, 
                        builder: (context){
                          return ChapterSelectDialog(param: param, chapter: chapter);
                        }
                      );
                    }),
                  ),
                  EmptyFlex(flex: 3)
                ]
            )
            );
          }).toList(),
      //       )
      //     )
      //   );
      // }
      
    );
  }
  

  @override
  Widget build(BuildContext context) {
    param = ModalRoute.of(context)!.settings.arguments as PracticeGameArguments;
    final size = MediaQuery.of(context).size;

    Widget screen = _build(context);

    return GameMenu(
      title: "Choose Topic", 
      japanese: "トピックを選択", 
      child: screen,
      type: param.gameType,
      footer: null,
    );
  }
}