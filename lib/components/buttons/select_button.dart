import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/theme.dart';


class SelectButton extends StatelessWidget {
  final String title;
  final String? description;
  final Function() onTap;
  final String? iconPath;

  EdgeInsetsGeometry? padding;

  SelectButton({Key? key, required this.title, this.description, required this.onTap, this.iconPath, this.padding}) : super(key: key);

  static const double _titleFontSize = 20;
  static const double _descFontSize = 14;

  final Color _titleTextColor = Colors.black;
  final Color _descTextColor = Colors.grey;

  Widget _withDescription(BuildContext context, Widget titleWidget) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: 
            titleWidget,
          ),
          
          Padding(
              padding: const EdgeInsets.only(top: 5),
              child: 
              Text(
                description!, 
                textAlign: TextAlign.left,
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
  Widget _withImage(BuildContext context) {
    return iconPath == null ? Center(child: Text(title, style: Theme.of(context).textTheme.button)) :
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.button,
          ),
          Image(
            image: AssetImage(iconPath!), 
            height: 35,
            width: 35,
            fit: BoxFit.fill,
          ) 
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget child =  _withImage(context);

    if (description != null) {
      child = _withDescription(context, child);
    }

    return Padding(
      padding: padding == null ? EdgeInsets.zero : padding!,
      child: TextButton(
        onPressed: onTap,
        child: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 7
            ),
            child: child,
          ),
          constraints: BoxConstraints(
            minHeight: size.height*0.075
          ),
          width: size.width*0.50,
          decoration: BoxDecoration(
            border: Border.all(
              width: 2
            ),
          ),
        )
      )
    );
  }

}