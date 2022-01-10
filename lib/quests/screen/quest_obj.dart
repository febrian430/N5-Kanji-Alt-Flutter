import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/theme.dart';

class QuestWidget extends StatelessWidget {
  final Widget title;
  final bool claimable;
  final QUEST_STATUS status;
  final int count;
  final int total;
  final int goldReward;
  final Function() onClaim;

  const QuestWidget({
    Key? key, 
    required this.title, 
    this.claimable = false,  
    required this.onClaim, 
    required this.status, 
    required this.count, 
    required this.total, 
    required this.goldReward
    }) : super(key: key);

  Widget _description(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        Expanded(flex: 8, child: title),
        Flexible(flex: 2, child: _reward(context))
      ],
    );
  }

  Widget _reward(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          AppIcons.currency, 
          height: 25,
          width: 25,
        ),
        Text("x${goldReward}")
      ],
    );
  }

  Widget _claimButton(BuildContext context) {
    ButtonStyle buttonStyle = TextButton.styleFrom(
      backgroundColor: AppColors.primary
    );
    Widget child = Text('$count/$total');
    if(status == QUEST_STATUS.CLAIMED) {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 4, 
            child: Image.asset(
              AppIcons.quiz,
              fit: BoxFit.cover,
              color: AppColors.correct,
            )
          ),
          Flexible(
            flex: 2, 
            child: Text(
              "Claimed",
              style: TextStyle(
                color: AppColors.correct  
              ),
            ),
          )
        ],
      );
    } else if(count >= total) {
      buttonStyle = TextButton.styleFrom(
        backgroundColor: AppColors.correct
      );
      child = Text(
        "Tap to Claim", 
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: TextButton(
      child: Center(child: child),
      onPressed: count < total || status == QUEST_STATUS.CLAIMED  ? null : onClaim,
      style: buttonStyle,)
    );
  }


  Widget questWidget(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height*0.113,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(flex: 8, child: _description(context)),
          Flexible(
            flex: 3,
            child: Column(
              children: [
                Visibility(
                  visible: true,
                  child: Flexible(
                    flex: 6,
                    child: Center(child: _claimButton(context))
                  )
                ),
              ],
            )
          )
        ]
      )
    );
  }
  
  @override
  Widget build(BuildContext context) => questWidget(context);

}