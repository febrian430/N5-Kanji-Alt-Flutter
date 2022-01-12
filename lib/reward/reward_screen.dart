import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/database/user_point.dart';
import 'package:kanji_memory_hint/menu_screens/menu.dart';
import 'package:kanji_memory_hint/quests/screen/gold.dart';
import 'package:kanji_memory_hint/reward/reward_screen_layout.dart';
import 'package:kanji_memory_hint/reward/topic_reward.dart';
import 'package:kanji_memory_hint/theme.dart';

class RewardScreen extends StatefulWidget {
  
  static const route = '/rewards';
  static const name = 'Reward';
  final chapters = [1,2,3];

  RewardScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  late Future<List<Example>> futureExamples;
  late Future<UserPoint> point;
  int gold = 0;
  bool goldLoaded = false;
  bool exampleLoaded = false;
  late List<Example> examples;

  @override
  void initState() {
    super.initState();

    futureExamples = SQLRepo.examples.all();
    point = SQLRepo.userPoints.get();
  }

  Widget _pageView(BuildContext context){
    final size = MediaQuery.of(context).size;

    List<List<Example>> groupedPerChapter = widget.chapters.map((chapter){
      var examplesOfChapter = examples.where((example) => example.chapter == chapter);
      return examplesOfChapter.toList();
    }).toList();

    return PageView(
      controller: PageController(
        viewportFraction: 1,
      ),
      children: groupedPerChapter.map((examples) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width*0.062),
          child: TopicRewards(
            examples: examples, 
            gold: gold,
            onBuy: (int cost, int exampleId) {
              
              setState(() {
                gold -= cost;

                // examples = examples.where((example) => example.id == exampleId).
              });
            },
          )
        );
      }).toList(),
    );
  }

  Widget screen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1
        ),
        color: AppColors.primary
      ),
      child: FutureBuilder(
        future: futureExamples,
        builder: (context, AsyncSnapshot<List<Example>> snapshot) {

          if(snapshot.hasData){
            if(!exampleLoaded) {
              examples = snapshot.data!;
              exampleLoaded = true;
            }
            
            return _pageView(context);
          } else {
            return LoadingScreen();
          }
        }
      )
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder(
        future: point,
        builder: (context, AsyncSnapshot<UserPoint> snapshot) {
          if(snapshot.hasData && !goldLoaded) {
            gold = snapshot.data!.gold;
            goldLoaded = true;
          }
          return RewardScreenLayout(
            child: screen(context),
            gold: GoldWidget(gold: gold,)
          );
        }
    ); 
  }
}