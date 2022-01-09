import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final Function() onTap;
  final String iconPath;
  final double height;
  final double width;
  final Color backgroundColor;
  final double iconSize;
  final double ratio;
  final bool noBorder;

  const AppIconButton({
      Key? key, 
      required this.onTap, 
      required this.iconPath, 
      required this.height, 
      required this.width, 
      required this.backgroundColor,
      this.ratio = 1,
      this.iconSize = 30,
      this.noBorder = false
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: ratio, 
      child: TextButton(
        onPressed: onTap, 
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          side: noBorder ? BorderSide.none : null
        ),
        child: Container(
          height: height,
          width: width,
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