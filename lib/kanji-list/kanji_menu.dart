import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/database/kanji.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/kanji-list/parameter.dart';
import 'package:kanji_memory_hint/kanji-list/tile_alt.dart';
import 'package:kanji_memory_hint/menu_screens/menu.dart';
import 'package:kanji_memory_hint/theme.dart';
import 'package:kanji_memory_hint/map_indexed.dart';


class KanjiList extends StatefulWidget {
  KanjiList({Key? key}) : super(key: key);

  static const route = "/list";
  final List<int> chapters = [1,2,3,4,5,6,7,8];
  // final List<int> chapters = [1,2,3];
  
  Future<List<Kanji>> _getList() async {
    return SQLRepo.kanjis.all();
  }

  @override
  State<StatefulWidget> createState() => _MenuState();
}

class _MenuState extends State<KanjiList> {
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
          onPressed: () {
            Navigator.of(context).pushNamed("/list/view",
              arguments: KanjiViewParam(kanjis, index));
          }
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

    return Menu(title: "Kanji List", japanese: "漢字 リスト", child: screen);
  }
}