import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';

class ScreenLayout extends StatelessWidget {

  final Widget header;
  final Widget child;
  final Widget? footer;
  final bool topPadding;
  final bool bottomPadding;
  final double? customTopPadding;
  final double? customBottomPadding;
  final double? customHorizontalPadding;
  final bool horizontalPadding;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const ScreenLayout({Key? key, 
    required this.header, 
    this.footer, 
    required this.child, 
    this.topPadding = true, 
    this.bottomPadding = true, 
    this.horizontalPadding = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.customBottomPadding,
    this.customTopPadding,
    this.customHorizontalPadding
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: SafeArea(
        child: Container(
          // decoration: BoxDecoration(
          //   border: Border.all(
          //     width: 1
          //   )
          // ),
          padding: EdgeInsets.only(
            top: topPadding ? (customTopPadding ?? size.height*.045) : 0,
            bottom: bottomPadding ? (customBottomPadding ?? size.height*.045) : 0,
            right: horizontalPadding ? (customHorizontalPadding ?? size.width*.032) : 0,
            left: horizontalPadding ? (customHorizontalPadding ?? size.width*.032) : 0
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