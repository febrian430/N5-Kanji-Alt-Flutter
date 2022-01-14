import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/header.dart';

class QuestScreenLayout extends StatelessWidget {
  final Widget content;
  final Widget footer;

  const QuestScreenLayout({Key? key, required this.content, required this.footer}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: size.height*.045,
          ),
          child: Column(
            children: [
              Flexible(
                flex: 12, 
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: AppHeader(title: "Quest", japanese: "クエスト", withBack: true,),
                    ),
                    Expanded(
                      flex: 11,
                      child: content,
                    )
                  ],
                ),
              ),
                // Stack(
              //     children: [
              //       content,
              //       SizedBox(height: size.height*0.1, 
              //         child: AppHeader(title: "Quest", japanese: "in japanese"),
              //       )
              //     ],
              //   )
              // ),
              Expanded(
                flex: 1,
                child: footer
              ),
            ],
          )
        )
      )
    ); 
  }
}