import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/reward/dialog.dart';
import 'package:kanji_memory_hint/theme.dart';

class TopicRewards extends StatefulWidget {
  final List<Example> examples;
  final int gold;
  final Function(int, int) onBuy;
  final Function()? onNext;
  final Function()? onPrev;

  const TopicRewards({
    Key? key, 
    required this.examples,
    required this.gold,
    required this.onBuy,
    required this.onNext,
    required this.onPrev
  }) : super(key: key);
  
  
  @override
  State<StatefulWidget> createState() => _TopicRewardsState();

}

class _TopicRewardsState extends State<TopicRewards> {

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      print("GOLD IS ${widget.gold}");
    });

    return Column(
        children: [
          Expanded(
            flex: 2,
            child: _header(context)
          ),
          Expanded(
            flex: 10,
            child:  GridView.count(
                crossAxisCount: 5,
                crossAxisSpacing: 7,
                mainAxisSpacing: 7,
                childAspectRatio: 3/4,
                children: widget.examples.map((example) {
                  return GestureDetector(
                    onTap: () { 
                      showDialog(
                        context: context, 
                        builder: (context) {
                          return RewardDialog(
                            example: example,
                            gold: widget.gold,
                            onBuy: widget.onBuy,
                          );
                        }
                      ); 
                    },
                    child: _RewardItem(example: example,));
                }).toList(),
            )
          )
        ],
      );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        EmptyFlex(flex: 1),
        Expanded(
          flex: 2,
          child: widget.onPrev != null ?
           TextButton(
            child: Image.asset(AppIcons.prev),
            onPressed: widget.onPrev,
            style: TextButton.styleFrom(
              side: BorderSide.none
            ),
          ) : SizedBox()
        ),
        EmptyFlex(flex: 1),
        Expanded(
          flex: 5,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(width: 2)
            ),
            child: Text(
              "Topic ${widget.examples[0].chapter}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
          )
        ),
        EmptyFlex(flex: 1),

        Expanded(
          flex: 2,
          child: widget.onNext != null ? TextButton(
            child: Image.asset(AppIcons.next),
            onPressed: widget.onNext,
            style: TextButton.styleFrom(
              side: BorderSide.none
            ),
          ) : SizedBox()
        ),
        EmptyFlex(flex: 1),

      ],
    );
  }
}

class _RewardItem extends StatelessWidget {
  final Example example;

  const _RewardItem({
    Key? key, 
    required this.example
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1)
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                KANJI_IMAGE_FOLDER+example.image,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 1)),
              ),
              child: example.rewardStatus == REWARD_STATUS.AVAILABLE ?
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(example.cost.toString(), textAlign: TextAlign.end,)
                  ),
                  Expanded(
                    flex: 2,
                  child: Image.asset(AppIcons.currency, fit: BoxFit.contain)
                  )
                ],
              ):
              Text(
                "Bought", 
                style: TextStyle(
                  color: AppColors.bought,
                  fontWeight: FontWeight.bold
                ),
              )
            ),
          )
        ]
      )
    );
  }
}