import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/color_hex.dart';
import 'package:kanji_memory_hint/const.dart';

class PracticeBackground extends StatelessWidget {
  
  final Widget child;

  const PracticeBackground({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage(APP_IMAGE_FOLDER+'main_menu.png'),
          fit: BoxFit.fill
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
              HexColor.fromHex("f9e7b1"),
              HexColor.fromHex("f9e7b1"),
              HexColor.fromHex("f8b444")
          ],
          tileMode: TileMode.decal, // repeats the gradient over the canvas
        )
      )
    );
  }


}