import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';

class ScreenLayout extends StatelessWidget {

  final Widget header;
  final Widget child;
  final Widget? footer;
  final bool verticalPadding;
  final bool horizontalPadding;

  const ScreenLayout({Key? key, 
    required this.header, 
    this.footer, 
    required this.child, 
    this.verticalPadding = true, 
    this.horizontalPadding = true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1
            )
          ),
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding ? size.height*.045 : 0,
            horizontal: horizontalPadding ? size.width*.032 : 0
          ),
          child: Container(
            child: Column(
              children: [
                Flexible(
                  flex: 1, 
                  child: header,
                ),
                Expanded(
                  flex: 8,
                  child: child
                ),
                footer != null ? Flexible(
                  flex: 1,
                  child: footer!
                )
                :
                EmptyWidget
              ],
            )
          )
        )
      )
    );
  }

}