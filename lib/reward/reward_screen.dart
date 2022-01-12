import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/database/repository.dart';
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
  late Future<List<Example>> examples;

  @override
  void initState() {
    super.initState();

    examples = SQLRepo.examples.all();
  }

  Widget _pageView(BuildContext context, List<Example> examples){
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
          child: TopicRewards(examples: examples,)
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
        future: examples,
        builder: (context, AsyncSnapshot<List<Example>> snapshot) {
          if(snapshot.hasData){
            return _pageView(context, snapshot.data!);
          } else {
            return LoadingScreen();
          }
        }
      )
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return RewardScreenLayout(
      child: screen(context),
      gold: GoldWidget(gold: 0,),
    ); 
  }
}