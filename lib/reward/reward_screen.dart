import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/menu_screens/menu.dart';
import 'package:kanji_memory_hint/quests/screen/gold.dart';
import 'package:kanji_memory_hint/theme.dart';

class RewardScreen extends StatefulWidget {
  
  static const route = '/rewards';
  static const name = 'Reward';

  RewardScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {

  Widget screen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height*0.8,
      width: size.width,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1
        ),
        color: AppColors.primary
      ),
      child: Column(
        children: [
          SizedBox(),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Menu(
      title: "Reward", 
      japanese: "褒美", 
      child: screen(context),
      topRight: GoldWidget(gold: 0,),
    ); 
  }
}