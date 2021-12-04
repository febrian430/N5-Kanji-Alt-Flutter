import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/repository/kanji_list.dart';
import 'package:kanji_memory_hint/repository/repo.dart';

class KanjiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var param = ModalRoute.of(context)!.settings.arguments as Kanji;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //rune
              Container(
                height: 100,
                width: 100,
                child: Center(
                  child: Text(
                    param.rune,
                    style: TextStyle(
                      fontSize: 50,
                    ),  
                  )
                ),
              ),

              //meaning
              Container(
                height: 100,
                child: Center(
                  child: Text(param.chapter.toString())
                ),
              ),
              //onyomi kunyomi
              Container(
                height: 50,
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     width: 1
                //   )
                // ),
                child: Row(
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width/2)-1,
                      child: Column(
                        children: param.kunyomi.map((kunyomi) {
                          return Center(child: Text(kunyomi),);
                        }).toList(),
                      ),
                    ),
                    Container(
                      width: (MediaQuery.of(context).size.width/2)-1,
                      child: Column(
                        children: param.onyomi.map((onyomi) {
                          return Center(child: Text(onyomi),);
                        }).toList(),
                      )
                    ),
                  ],
                )
              ),
              Container(
                height: 500,
                child: GridView.count(
                  crossAxisCount: 2,
                  children: param.examples.map((example) {
                    return Example(example: example);
                  }).toList(),
                ),
              )
            ],
          )
        ),
      )
    );
  }
}

class Example extends StatelessWidget {
  Example({Key? key, required this.example, this.height, this.width}) : super(key: key);

  final KanjiExample example;
  double? height;
  double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(example.rune), 
            Text(example.meaning), 
            Text(example.spelling), 
          ],
        )
      )
    );
  }
}