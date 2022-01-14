import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/theme.dart';

class QuestProgressBar extends StatelessWidget {
  final int count;
  final int total;

  const QuestProgressBar({Key? key, required this.count, required this.total}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("$count/$total", style: TextStyle(fontWeight: FontWeight.bold),),
        LinearProgressIndicator(
          value: count/total,
          backgroundColor: AppColors.selected,
          color: AppColors.secondary,
          minHeight: 5,
        )
      ],
    );
  }

}