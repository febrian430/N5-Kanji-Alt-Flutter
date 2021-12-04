import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/repository/kanji_list.dart';

class Menu extends StatefulWidget {
  Menu({Key? key}) : super(key: key);

  static const route = "/list";
  final List<int> chapters = [1,2,3,4,5,6,7,8];
  
  Future<List<Kanji>> _getList() async {
    return await kanjiList();
  }

  @override
  State<StatefulWidget> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override

  var _list;

  @override
  void initState() {
    _list = widget._getList();
  }

  Widget _renderList(BuildContext context, List<Kanji> kanjis) {
    return SingleChildScrollView(
          child: Center(
            child: Column(
              children: 
                widget.chapters.map((chapter) {
                  return ExpansionTile(
                    expandedCrossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        children: kanjis.where((kanji) => kanji.chapter == chapter)
                          .map((kanji) {
                            return TextButton(
                              onPressed: () => Navigator.of(context).pushNamed("/list/view",
                                arguments: kanji
                              ),
                              child: Text(kanji.rune),
                            );
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
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _list,
          builder: (context, AsyncSnapshot<List<Kanji>> snapshot) {
            if(snapshot.hasData) {
              return _renderList(context, snapshot.data!);
            } else {
              return Center(
                child: Text("Loading..."),
              );
            }
          }
        )
      ),
    );
  }
}