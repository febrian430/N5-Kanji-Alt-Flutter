import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/theme.dart';

class GoldWidget extends StatelessWidget {
  final int gold;
  final Color color;
  final double fontSize;
  const GoldWidget({Key? key, required this.gold, this.color = Colors.black, this.fontSize = 18}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            gold.toString(), 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color
            ),  
          )
        ),
        Expanded(
          flex: 1,
          child: Center(child: Image.asset(AppIcons.currency))
        )
      ],
    );
  }

}