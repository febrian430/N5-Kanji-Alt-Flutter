import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/containers/double_border_container.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/quests/screen/gold.dart';
import 'package:kanji_memory_hint/reward/save_image.dart';
import 'package:kanji_memory_hint/theme.dart';

class RewardDialog extends StatefulWidget {
  final Example example;
  final int gold;
  final Function(int, int) onBuy;

  RewardDialog({
    Key? key, 
    required this.example, 
    required this.gold,
    required this.onBuy
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RewardDialogState();
}

class _RewardDialogState extends State<RewardDialog> {
  // bool bought = false;
  late int gold = widget.gold;
  late Example example = widget.example;

  Widget _header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 4, child: SizedBox(),),
                Expanded(flex: 4, child: Text("Topic ${widget.example.chapter.toString()}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                Flexible(flex: 3, child: GoldWidget(gold: gold, textAlign: TextAlign.right,))
              ],
            )
          ),
          Expanded(
            child: Text(
              widget.example.rune, 
              style: TextStyle(fontFamily: "MsMincho", fontSize: 40)
            ),
          )
        ],
      )
    );
  }

  Widget _image(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 1)),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.asset(
          KANJI_IMAGE_FOLDER+widget.example.image,
          fit: BoxFit.contain,
        ),
      )
    );
  }

  Widget saveImageDialog(BuildContext context) {
    return AlertDialog(
      title: Text("Image saved!", textAlign: TextAlign.center),
      actions: [
        TextButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
          child: Text("OK")
        )
      ],
      content: Text(
        "Image has been saved to your Download folder under kantan_kanji_library folder",
        textAlign: TextAlign.center
      ),
    );
  }

  Widget _getActionButton(BuildContext context, BoxConstraints constraints) {
    return example.rewardStatus == REWARD_STATUS.AVAILABLE ? 
    TextButton(
      onPressed: (){
        if(widget.example.cost <= gold) {
          setState(() {
            // bought = !bought;
            gold -= widget.example.cost;
            example.claim();
            example.rewardStatus = REWARD_STATUS.CLAIMED;
            widget.onBuy(widget.example.cost, widget.example.cost);
          });
        } else {
          showDialog(
            context: context, 
            builder: (context) {
              return AlertDialog(
                title: Text("Insufficient Ryo", textAlign: TextAlign.center),
                content: Text(
                  "You got insufficient Ryo. Finish quests to get more Ryo!",
                  textAlign: TextAlign.center
                ),
                actions: [          
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    }, 
                    child: Text("OK")
                  )
                ],
              );
            }
          );
        }
      }, 
      style: TextButton.styleFrom(
        backgroundColor: AppColors.correct
      ),
      child: SizedBox(
        width: constraints.maxWidth,
        child: Container(
          margin: EdgeInsets.all(6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text("Buy", style: TextStyle(color: Colors.white),)),
              Flexible(child: GoldWidget(gold: widget.example.cost, color: Colors.white, textAlign: TextAlign.right,))    
            ],
          )
        )
      )
    )
    :
    TextButton(
      onPressed: () async {
        await saveImage(widget.example.image);
        showDialog(
          context: context, 
          builder: (context) {
            return saveImageDialog(context);
          }
        );
      }, 
      style: TextButton.styleFrom(
        backgroundColor: AppColors.primary
      ),
      child: SizedBox(
        width: constraints.maxWidth,
        child: Container(
          margin: EdgeInsets.all(6),
          child: Text(
            "Save to Library", 
            textAlign: TextAlign.center, 
            style: TextStyle(
              color: Colors.black
            ),
          )
        )
      )
    );
  }

  Widget _buttons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(flex: 1, child: SizedBox()),

        Expanded(
          flex: 6, 
          child: LayoutBuilder(
            builder: (context, constraints) {
              return _getActionButton(context, constraints);
            }
          )
        ),
        Expanded(flex: 1, child: SizedBox()),

        Expanded(
          flex: 4, 
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox()
              ),
              Expanded(
                flex: 2,
                child: AspectRatio(
                  aspectRatio: 5/16,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.wrong
                    ),
                    onPressed: (){
                      Navigator.of(context).pop();
                    }, 
                    child: Center(child: Text("Close", style: TextStyle(color: Colors.white),))
                  ) 
                )
              ),
              Expanded(
                flex: 1,
                child: SizedBox()
              ),
            ]
          )
        ),

      ],
    );
  }

  Widget _content(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth*.8),
          child: Column(
            children: [
              Expanded(
                flex: 16,
                child: _image(context)
              ),
              Expanded(
                flex: 1,
                child: SizedBox()
              ),
              Expanded(
                flex: 8,
                child: _buttons(context)
              )
            ],
          )
        );
      }
    );
  }

  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      child: TwoBorderContainer(
        width: size.width*.8,
        height: size.height*.7,
        decoration: BoxDecoration(
          border: Border.all(width: 1)
        ),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 6),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: _header(context)
            ),
            Expanded(
              flex: 12,
              child: _content(context)
            ),
          ],
        ),
      ),
    ); 
  }

 

}