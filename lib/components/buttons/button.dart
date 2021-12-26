import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/color_hex.dart';
import 'package:kanji_memory_hint/theme.dart';

class AppButton extends StatelessWidget {
  final String title;
  final Function() onTap;

  AppButton({Key? key, required this.title, required this.onTap}) : super(key: key) {
    _buttonColor = HexColor.fromHex(AppButtonTheme.buttonColor);
    _titleTextColor = Colors.black;
  }

  static const double _titleFontSize = 22;
  static const double _descFontSize = 14;

  late Color _buttonColor;
  late Color _titleTextColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return TextButton(
      onPressed: onTap,
      child: Container(
        child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: _titleFontSize,
                color: _titleTextColor
              ),
            ),
        ),
        constraints: BoxConstraints(
          minHeight: size.height*0.10
        ),
        width: size.width*0.4,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1
          ),
          color: _buttonColor,
        ),
      )
    );
  }

}