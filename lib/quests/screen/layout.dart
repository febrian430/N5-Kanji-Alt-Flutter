import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/select_button.dart';
import 'package:kanji_memory_hint/components/header.dart';

class QuestScreenLayoutAlt extends StatelessWidget {
  final Widget progressWidget;
  final Widget questWidget;
  final Widget footer;

  const QuestScreenLayoutAlt({
    Key? key, 
    required this.progressWidget,
    required this.questWidget,
    required this.footer
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child:  Column(
          children: [
            SizedBox(
              height: size.height*.85,
              // width: size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: size.height*.15,
                      width: size.width,
                      padding: EdgeInsets.only(
                        top: size.height*.045
                      ),
                      child:AppHeader(title: "Quest", japanese: "クエスト", withBack: true,),
                    ),

                    SizedBox(
                      height: size.height*.4,
                      width: size.width,

                      child: progressWidget
                    ),
                    SizedBox(
                      height: size.height*.76,
                      width: size.width,

                      child: questWidget
                    ),
                  ]
                )
              )
            ),
            SizedBox(
              height: size.height*.15, 
              child: footer
            )
          ]
        )
      ),
    );
  }

}