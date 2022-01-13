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
  static const List<int> chapters = [1,2,3,4,5,6,7,8]; 
  late PracticeGameArguments param;

  Widget _build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return  ListView(
        padding: EdgeInsets.only(top: size.height*.05),
      children: chapters.map((chapter){
          return Padding(
            padding: EdgeInsets.symmetric(vertical: size.height*.0062),
            child: Row(
              children: [
                EmptyFlex(flex: 2),
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
                EmptyFlex(flex: 2)
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
      footer: EmptyWidget,
    );
  }

}

class ChapterSelect2 extends StatefulWidget {
  const ChapterSelect2({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChapterSelect2State();

}

class _ChapterSelect2State extends State<ChapterSelect2> {
  int? selected;

  @override
  Widget build(BuildContext context) {
    var param = ModalRoute.of(context)!.settings.arguments as PracticeGameArguments;

    return GameMenu(
      title: "Choose Topic", 
      japanese: "トピックを選択", 
      child: _KanjiChapterList(
        onTap: (index) {
          print("INDEX SELECT: $index");
          setState(() {
            selected = index;
          });
        },
      ),
      type: param.gameType,
      footer: Visibility(
        visible: selected != null,
          child: AppIconButton(
          onTap: (){
            param.chapter = selected!;
            Navigator.pushNamed(context, param.selectedGame, arguments: param);
          }, 
          iconPath: AppIcons.resume, 
          height: 60, 
          width: 60, 
          backgroundColor: Colors.transparent,
          noBorder: true,
        ),
      )
    );
  }
}



class _KanjiChapterList extends StatefulWidget {
  _KanjiChapterList({Key? key, required this.onTap}) : super(key: key);

  final List<int> chapters = [1,2,3];
  final Function(int?) onTap;
  
  Future<List<Kanji>> _getList() async {
    return SQLRepo.kanjis.all();
  }

  @override
  State<StatefulWidget> createState() => _MenuState();
}

class _MenuState extends State<_KanjiChapterList> {
  @override

  var _list;

  ValueNotifier<Key?> _expanded = ValueNotifier(null);

  var selected;


  @override
  void initState() {
    _list = widget._getList();
  }

  Widget buildKanji(BuildContext context, List<Kanji> kanjis, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1
        )
      ),
      child: TextButton(
        child: Text(
          kanjis[index].rune,
          style: TextStyle(
            color: Colors.black
          ),
        ),
        onPressed: null
      ),
    );
  }

  Widget _renderList(BuildContext context, List<Kanji> kanjis) {
    final screenWidth = MediaQuery.of(context).size.width;
    final childWidth = screenWidth*0.8;
    final width = screenWidth*0.55;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: 
            widget.chapters.mapIndexed((chapter, index) {
              final kanjisChapter = kanjis.where((kanji) => kanji.chapter == chapter).toList();

              return Padding(
                padding: EdgeInsets.all(6),
                child: KanjiTile2(
                  expandedItem: _expanded,
                  key: Key(index.toString()),
                  onExpansionChanged: (bool expanded){
                    if(expanded){
                      widget.onTap(index+1);
                    }else{
                      widget.onTap(null);
                    }
                  },
                  textColor: Colors.black,
                  iconColor: Colors.black,
                  backgroundColor: Colors.transparent,
                  childrenPadding: const EdgeInsets.all(4),
                  expandedCrossAxisAlignment: CrossAxisAlignment.end,
                  childWidth: childWidth,
                  width: width,
                  headerBackgroundColor: AppColors.primary,
                  maintainState: true,
                  headerBorderWidth: 2,
                  children: <Widget>[
                    GridView.count(
                      crossAxisCount: 5,
                      padding: const EdgeInsets.all(4),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: kanjisChapter.mapIndexed((kanji, index) {
                          return buildKanji(context, kanjisChapter, index);
                        }).toList() 
                    )
                  ],
                  title: Text(
                    "Topic ${chapter}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    )
                  )
                )
              );
            }).toList()
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
    final screen = FutureBuilder(
      future: _list,
      builder: (context, AsyncSnapshot<List<Kanji>> snapshot) {
        if(snapshot.hasData) {
          return SizedBox(
            height: height*0.75,
            child: _renderList(context, snapshot.data!)
          );
        } else {
          return Center(
            child: LoadingScreen(),
          );
        }
      }
    );

    return screen;
  }
}