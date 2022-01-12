import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/reward/dialog.dart';

class TopicRewards extends StatefulWidget {
  // final List<Example> examples;

  const TopicRewards({
    Key? key, 
    // required this.examples
  }) : super(key: key);
  
  
  @override
  State<StatefulWidget> createState() => _TopicRewardsState();

}

class _TopicRewardsState extends State<TopicRewards> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { 
        showDialog(
          context: context, 
          builder: (context) {
            return RewardDialog();
          }
        ); 
      },
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: _header(context)
          ),
          Expanded(
            flex: 9,
            child:  GridView.count(
                crossAxisCount: 5,
                childAspectRatio: 3/4,
                children: [ 
                // widget.examples.map((e) => SizedBox()).toList()
                  _RewardItem(),
                  _RewardItem(),
                  _RewardItem(),
                  _RewardItem(),
                  _RewardItem(),
                  _RewardItem(),
                  _RewardItem(),
                  _RewardItem(),
                  _RewardItem(),
                  _RewardItem(),
                ]
              ),
            )
          
        ],
      )
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Text("<"),
        Text("Topic 1"),
        Text(">")
      ],
    );
  }
}

class _RewardItem extends StatelessWidget {
  // final Example example;

  const _RewardItem({
    Key? key, 
    // required this.example
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
                KANJI_IMAGE_FOLDER+'30kr1n.png',
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
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text("123", textAlign: TextAlign.end,)
                  ),
                  Expanded(
                    flex: 2,
                    child: Image.asset(AppIcons.currency, fit: BoxFit.contain)
                  )
                ],
              ),
            ),
          )
        ]
      )
    );
  }
}