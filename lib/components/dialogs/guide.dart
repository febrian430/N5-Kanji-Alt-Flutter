import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/images.dart';
import 'package:kanji_memory_hint/theme.dart';

class GuideDialog extends StatelessWidget {
  final String game;
  final String guideImage;
  final String description;
  final Function() onClose;

  const GuideDialog({
    Key? key, 
    required this.game, 
    required this.guideImage, 
    required this.description, 
    required this.onClose
  }) : super(key: key);

  Widget _guide(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 1,
          child: Text(
            game,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold
            )
          ),
        ),
        Expanded(
          flex: 3,
          child: Image.asset(guideImage),
        ),
        Expanded(
          flex: 1,
          child: Text(description, style: Theme.of(context).textTheme.subtitle2,)
        ),
      ],
    );
  }

  Widget buildDialog(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      shape: BeveledRectangleBorder(
        side: BorderSide(width: 1)
      ),
      child: Container(
        height: size.height*0.7,
        width: size.width*0.6,
        padding: EdgeInsets.all(6),
        child: Container( 
          decoration: BoxDecoration(
            border: Border.all(
              width: 1
            ),
          ),
          padding: EdgeInsets.fromLTRB(20, 6, 20, 6),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Text("How to play", style: Theme.of(context).textTheme.headline6),
              ),
              Expanded(
                flex: 8,
                child: _guide(context)
              ),
              Flexible(
                flex: 1,
                child: SizedBox(
                  width: size.width*0.3,
                  height: size.height*0.1,
                  child: TextButton(
                    child: Text(
                      "Got it!",
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                    onPressed: (){
                      Navigator.of(context).pop();
                      onClose();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.wrong
                    ),
                  )
                )
              )
            ],
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: buildDialog(context), 
      onWillPop: () async {
        onClose();
        return true;
      }
    );
  }
}