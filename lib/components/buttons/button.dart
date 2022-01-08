import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/color_hex.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/theme.dart';

class AppButton extends StatelessWidget {
  final Function() onTap;

  const AppButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return IconButton(
      onPressed: onTap, 
      icon: Image.asset(APP_IMAGE_FOLDER+'back.png')
    );
  }

}