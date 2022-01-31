import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/theme.dart';

class LevelProgressBar extends StatelessWidget {
  final int upperbound;
  int? lowerbound;
  final int current;

  LevelProgressBar({Key? key, required this.upperbound, this.lowerbound, required this.current}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Expanded(child: lowerbound != null ? Text(lowerbound.toString()) : SizedBox()),
            Expanded(child: Text(current.toString(), textAlign: TextAlign.center,)),
            Expanded(child: Text(upperbound.toString(), textAlign: TextAlign.end,))
          ],
        ),
        LinearProgressIndicator(
          backgroundColor: AppColors.cream,
          color: AppColors.secondary,
          value: current/upperbound,
          minHeight: 10,
        ),
      ],
    );
  }

}