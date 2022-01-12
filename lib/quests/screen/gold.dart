import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/theme.dart';

class GoldWidget extends StatelessWidget {
  final int gold;
  final Color color;
  const GoldWidget({Key? key, required this.gold, this.color = Colors.black}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            gold.toString(), 
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color
            ),  
          )
        ),
        Flexible(
          flex: 1,
          child: Center(child: Image.asset(AppIcons.currency))
        )
      ],
    );
  }

}