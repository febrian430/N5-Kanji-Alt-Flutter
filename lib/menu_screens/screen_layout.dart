import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScreenLayout extends StatelessWidget {

  final Widget header;
  final Widget child;
  final Widget footer;

  const ScreenLayout({Key? key, required this.header, required this.footer, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: size.width*.075,
            horizontal: size.height*.05
          ),
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
              Flexible(
                flex: 1,
                child: footer
              )
            ],
          )
        )
      )
    );
  }

}