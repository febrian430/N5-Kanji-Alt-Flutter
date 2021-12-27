import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/menu_screens/menu.dart';
import 'package:kanji_memory_hint/repository/kanji_list.dart';
import 'package:kanji_memory_hint/theme.dart';

class KanjiMenu extends StatefulWidget {
  KanjiMenu({Key? key}) : super(key: key);

  static const route = "/list";
  final List<int> chapters = [1,2,3,4,5,6,7,8];
  
  Future<List<Kanji>> _getList() async {
    return await kanjiList();
  }

  @override
  State<StatefulWidget> createState() => _MenuState();
}

class _MenuState extends State<KanjiMenu> {
  @override

  var _list;

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
          child: Text(kanji.rune),
        )
    );
  }

  Widget _renderList(BuildContext context, List<Kanji> kanjis) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: 
            widget.chapters.map((chapter) {
              return ExpansionTile(
                textColor: Colors.black,
                backgroundColor: Colors.transparent,
                childrenPadding: const EdgeInsets.all(4),
                expandedCrossAxisAlignment: CrossAxisAlignment.end,
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

  Widget build(BuildContext context) {
    final screen = FutureBuilder(
      future: _list,
      builder: (context, AsyncSnapshot<List<Kanji>> snapshot) {
        if(snapshot.hasData) {
          return _renderList(context, snapshot.data!);
        } else {
          return Center(
            child: LoadingScreen(),
          );
        }
      }
    );

    return Menu(title: "Kanji List", titleJapanese: "in japanese", child: screen);
  }
}