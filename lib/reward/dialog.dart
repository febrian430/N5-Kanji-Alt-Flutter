import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/containers/double_border_container.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/quests/screen/gold.dart';
import 'package:kanji_memory_hint/theme.dart';

class RewardDialog extends StatefulWidget {
  // final Example example;
  int gold = 5;

  RewardDialog({
    Key? key, 
    // required this.example
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RewardDialogState();
}

class _RewardDialogState extends State<RewardDialog> {
  bool bought = false;

  Widget _header(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 4, child: SizedBox(),),
              Expanded(flex: 4, child: Text("Topic 1", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: GoldWidget(gold: 5))
            ],
          )
        ),
        Expanded(
          child: Text("一", style: TextStyle(fontFamily: "MsMincho", fontSize: 60)),
        )
      ],
    );
  }

  Widget _image(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 1)),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.asset(
          KANJI_IMAGE_FOLDER+'30kr1n.png',
          fit: BoxFit.contain,
        ),
      )
    );
  }

  Widget _getActionButton(BuildContext context) {
    return !bought ? Container(
      margin: EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text("Buy", style: TextStyle(color: Colors.white),)),
          Flexible(child: GoldWidget(gold: 1, color: Colors.white,))    
        ],
      )
    )
    :
    Text(
      "Save to Library", 
      textAlign: TextAlign.center, 
      style: TextStyle(
        color: Colors.black
      ),
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
              return TextButton(
                onPressed: (){
                  setState(() {
                    bought = !bought;
                  });
                }, 
                style: TextButton.styleFrom(
                  backgroundColor: !bought ? AppColors.correct : AppColors.primary
                ),
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: _getActionButton(context)
                )
              );
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