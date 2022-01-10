import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/color_hex.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/theme.dart';

class QuizBackground extends StatelessWidget {
  
  final Widget child;

  const QuizBackground({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppBackgrounds.quiz),
          fit: BoxFit.fill
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
              AppColors.purple,
              HexColor.fromHex("f8b444")
          ],
          tileMode: TileMode.decal, // repeats the gradient over the canvas
        )
      )
    );
  }


}