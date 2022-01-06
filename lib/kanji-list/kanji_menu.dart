import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/database/kanji.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/kanji-list/tile.dart';
import 'package:kanji_memory_hint/menu_screens/menu.dart';
import 'package:kanji_memory_hint/theme.dart';
import 'package:kanji_memory_hint/map_indexed.dart';


class KanjiMenu extends StatefulWidget {
  KanjiMenu({Key? key}) : super(key: key);

  static const route = "/list";
  // final List<int> chapters = [1,2,3,4,5,6,7,8];
  final List<int> chapters = [1,2,3];
  
  Future<List<Kanji>> _getList() async {
    return SQLRepo.kanjis.all();
  }

  @override
  State<StatefulWidget> createState() => _MenuState();
}

class _MenuState extends State<KanjiMenu> {
  @override

  var _list;

  int selected = -1;

  @override
  void initState() {
    _list = widget._getList();
  }

  Widget buildKanji(BuildContext context, Kanji kanji) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1
          )
        ),
        child: TextButton(
          onPressed: () => Navigator.of(context).pushNamed("/list/view",
            arguments: kanji
          ),
          child: Text(
            kanji.rune,
            style: TextStyle(
              color: Colors.black
            ),
          ),
        )
    );
  }

  Widget _instantPopList(BuildContext context, List<Kanji> kanjis) {
    final screenWidth = MediaQuery.of(context).size.width;
    final childWidth = screenWidth*0.8;
    final width = screenWidth*0.6;

    return ListView.builder(
      key: Key('builder ${selected.toString()}'),
      itemCount: widget.chapters.length,  
      itemBuilder: (context, index) {
        var chapter = widget.chapters[index];
        return Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10
            ),
            child: KanjiTile(
              key: Key(index.toString()),
              // initiallyExpanded: selected == index,
              // onExpansionChanged: (expanding) {
              //   if(expanding){
              //     setState(() {
              //       selected = index;
              //     });
              //   } else {
              //     setState(() {
              //       selected = -1;
              //     });
              //   }
              // },
              iconColor: Colors.black,
              textColor: Colors.black,
              childrenPadding: const EdgeInsets.all(4),
              expandedCrossAxisAlignment: CrossAxisAlignment.end,
              width: width,
              childWidth: childWidth,
              headerBackgroundColor: AppColors.primary,
              headerBorderWidth: 3,
              
              children: <Widget>[
                GridView.count(
                  crossAxisCount: 5,
                  padding: const EdgeInsets.all(4),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: kanjis.where((kanji) => kanji.chapter == chapter)
                    .map((kanji) {
                      return buildKanji(context, kanji);
                    }).toList() 
                )
              ],
              title: Text(
                  "Chapter ${chapter}",
              )
            )
        );
      }
    );
  }

  Widget _renderList(BuildContext context, List<Kanji> kanjis) {
    final screenWidth = MediaQuery.of(context).size.width;
    final childWidth = screenWidth*0.8;
    final width = screenWidth*0.6;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: 
            widget.chapters.map((chapter) {
              return KanjiTile(
                textColor: Colors.black,
                iconColor: Colors.black,
                backgroundColor: Colors.transparent,
                childrenPadding: const EdgeInsets.all(4),
                expandedCrossAxisAlignment: CrossAxisAlignment.end,
                childWidth: childWidth,
                width: width,
                headerBackgroundColor: AppColors.primary,
                maintainState: true,
                headerBorderWidth: 3,
                children: <Widget>[
                  GridView.count(
                    crossAxisCount: 5,
                    padding: const EdgeInsets.all(4),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: kanjis.where((kanji) => kanji.chapter == chapter)
                      .map((kanji) {
                        return buildKanji(context, kanji);
                      }).toList() 
                  )
                ],
                title: Center(
                  child: Text(
                    "Chapter ${chapter}"
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

    return Menu(title: "Kanji List", japanese: "in japanese", child: screen);
  }
}