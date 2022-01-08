import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final Function() onTap;
  final String iconPath;
  final double height;
  final double width;
  final Color backgroundColor;
  final double iconSize;

  const AppIconButton({
    Key? key, 
    required this.onTap, 
    required this.iconPath, 
    required this.height, 
    required this.width, 
    required this.backgroundColor,
    this.iconSize = 30}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1, child: TextButton(
      onPressed: onTap, 
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor
      ),
        child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.zero
        ),
        child: Image.asset(
          iconPath,
          width: iconSize,
          height: iconSize,
        ),
        )
      )
    );
  }
}