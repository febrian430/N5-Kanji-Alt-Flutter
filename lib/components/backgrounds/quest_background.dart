import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/color_hex.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/theme.dart';

class QuestBackground extends StatelessWidget {

  final Widget child;

  const QuestBackground({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      decoration: BoxDecoration(
        color: AppColors.primary
      )
    );
  }

}