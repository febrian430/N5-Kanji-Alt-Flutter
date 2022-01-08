import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/theme.dart';


class SelectButton extends StatelessWidget {
  final String title;
  final String? description;
  final Function() onTap;
  final String? iconPath;

  SelectButton({Key? key, required this.title, this.description, required this.onTap, this.iconPath}) : super(key: key) {
    _titleTextColor = Colors.black;
    _descTextColor = Colors.grey;
  }

  static const double _titleFontSize = 20;
  static const double _descFontSize = 14;

  late Color _titleTextColor;
  late Color _descTextColor;

  Widget _withDescription(BuildContext context, Widget titleWidget) {
    return Container(
      child: Column(
        children: [
          Padding(
            child: titleWidget,
            padding: const EdgeInsets.all(4),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                description!, 
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _descTextColor,
                  fontSize: _descFontSize,
                ),
              )
            )
          )
        ],
      ),
    );
  }
  Widget _withImage(BuildContext context) {
    return iconPath == null ? Text(title, style: Theme.of(context).textTheme.button) :
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.button,
          ),
          Image(
            image: AssetImage(iconPath!), 
            height: 30,
            width: 30,
            fit: BoxFit.fill,
          ) 
        ],
      ); 
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget child = Center(
      child: _withImage(context)
    );
    if (description != null) {
      child = _withDescription(context, child);
    }

    return TextButton(
      onPressed: onTap,
      child: Container(
        child: child,
        constraints: BoxConstraints(
          minHeight: size.height*0.075
        ),
        width: size.width*0.45,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2
          ),
        ),
      )
    );
  }

}