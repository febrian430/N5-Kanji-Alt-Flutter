import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/theme.dart';

class QuestWidget extends StatefulWidget {
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

  @override
  State<StatefulWidget> createState() => _QuestWidgetState();
}

class _QuestWidgetState extends State<QuestWidget> {

  late QUEST_STATUS status = widget.status;

  Widget _description(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        Expanded(flex: 8, child: widget.title),
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
        Text("x${widget.goldReward}")
      ],
    );
  }

  Widget _claimButton(BuildContext context) {
    ButtonStyle buttonStyle = TextButton.styleFrom(
      backgroundColor: AppColors.selected,
      side: BorderSide.none
    );
    Widget child = Text('${widget.count}/${widget.total}');
    if(status == QUEST_STATUS.CLAIMED) {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 4, 
            child: Image.asset(
              AppIcons.check,
              fit: BoxFit.contain,
              color: AppColors.correct,
              height: 30,
              width: 30,
            )
          ),
          Flexible(
            flex: 2, 
            child: Text(
              "Claimed",
              style: TextStyle(
                color: AppColors.correct,
                fontSize: 14,
                fontWeight: FontWeight.bold
              ),
            ),
          )
        ],
      );
    } else if(widget.count >= widget.total) {
      buttonStyle = TextButton.styleFrom(
        backgroundColor: AppColors.correct,
        side: BorderSide.none
      );
      child = Text(
        "Tap to Claim", 
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: TextButton(
        child: Center(child: child),
        onPressed: 
        widget.count < widget.total || status == QUEST_STATUS.CLAIMED  ? 
          null 
          : 
          (){
            widget.onClaim();
            setState(() {
              status = QUEST_STATUS.CLAIMED;
            });
          },
        style: buttonStyle,
      )
    );
  }


  Widget questWidget(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height*0.113,
      padding: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(
          width: 2
        ))
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