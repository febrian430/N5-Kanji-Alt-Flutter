import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/color_hex.dart';
import 'package:kanji_memory_hint/components/buttons/material_state_button.dart';
import 'package:kanji_memory_hint/theme.dart';

class SelectButton extends StatelessWidget {
  final String title;
  final String? description;
  final Function() onTap;

  SelectButton({Key? key, required this.title, this.description, required this.onTap}) : super(key: key) {
    _buttonColor = HexColor.fromHex(AppButtonTheme.buttonColor);
    _titleTextColor = Colors.black;
    _descTextColor = Colors.grey;
  }

  static const double _titleFontSize = 22;
  static const double _descFontSize = 14;

  late Color _buttonColor;
  late Color _titleTextColor;
  late Color _descTextColor;

  Widget _withDescription(BuildContext context, Widget titleWidget) {
    return Container(
      child: Column(
        children: [
          titleWidget,
          Center(
            child: Text(
              description!, 
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _descTextColor,
                fontSize: _descFontSize,
              ),
            )
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = HexColor.fromHex(AppButtonTheme.buttonColor);

    final size = MediaQuery.of(context).size;

    Widget child = Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: _titleFontSize,
                color: _titleTextColor
              ),
            ),
          );
    if (description != null) {
      child = _withDescription(context, child);
    }

    return TextButton(
      onPressed: onTap,
      child: Container(
        child: child,
        constraints: BoxConstraints(
          minHeight: size.height*0.10
        ),
        width: size.width*0.4,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1
          ),
          color: buttonColor,
        ),
      )
    );
  }

}