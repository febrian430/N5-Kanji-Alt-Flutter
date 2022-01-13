import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/theme.dart';


class SelectButton extends StatelessWidget {
  final String title;
  final String? description;
  final Function() onTap;
  final String? iconPath;
  final double? width;

  EdgeInsetsGeometry? padding;
  final bool mainScreen;

  SelectButton({Key? key, required this.title, this.description, required this.onTap, this.iconPath, this.padding, this.width, this.mainScreen = false}) : super(key: key);


  final TextStyle titleStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black
  );
  final TextStyle descStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black
  );

  Widget _withDescription(BuildContext context, Widget child) {
    return description != null ? Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: child,
          ),
          Expanded(
            flex: 2, 
            child: Text(
            description!, 
            textAlign: TextAlign.left,
            style: descStyle
            )
          )
        ],
      ),
    ) : child;
  }
  Widget _withImage(BuildContext context, Widget child) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: description != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 4, 
            child: child,
          ),
          Expanded(
            flex: 1,
            child: iconPath != null ? 
              Image(
                image: AssetImage(iconPath!), 
                fit: BoxFit.contain,
                height: mainScreen ? 30 : 60,
                width: mainScreen ? 30 : 60,
              )
              :
              SizedBox()
          )
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool onlyTitle = description == null && iconPath == null;
    print("ONLY TITLE: $onlyTitle");
    Widget child = Text(
      title, 
      style: titleStyle, 
      textAlign: onlyTitle ? TextAlign.center : null,
    );

    child = _withDescription(context, child);
    child =  _withImage(context, child);

    if(onlyTitle) {
      child = Center(child: child,);
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
            child: onlyTitle ? 
              Center(child: child) : child,
          ),
          constraints: description == null ? BoxConstraints(
            minHeight: size.height*.075,
          ) : null,
          height: description != null ? size.height*.18 : null,
          width: width ?? size.width*0.60,
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