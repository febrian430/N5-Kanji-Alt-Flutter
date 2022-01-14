import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/progress_bar.dart';
import 'package:kanji_memory_hint/components/quest_progress_bar.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/quests/screen/gold.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: widget.title),
        Expanded(
          flex: 2, 
          child: QuestProgressBar(
            count: widget.count,
            total: widget.total,
          )
        )
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
                fontSize: 12,
                fontWeight: FontWeight.bold
              ),
            ),
          )
        ],
      );
    } else {
      buttonStyle = TextButton.styleFrom(
        backgroundColor: widget.count < widget.total ? AppColors.selected:  AppColors.darkGreen,
        side: BorderSide.none
      );
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GoldWidget(
            gold: widget.goldReward, 
            color: widget.count < widget.total ? Colors.black : Colors.white,
            fontSize: 16,
          ),
          
          widget.count < widget.total ?
          SizedBox()
          :
          Text("Claim", 
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold
            )
          ),
        ]
        
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
          width: 1
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