import 'package:flutter/cupertino.dart';
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
      child: PageView(
        controller: PageController(
          viewportFraction: 1,
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: TopicRewards()
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: TopicRewards()
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: TopicRewards()
          ),
        ],
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