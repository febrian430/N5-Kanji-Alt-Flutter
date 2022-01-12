
import 'package:flutter/material.dart';

class TwoBorderContainer extends StatelessWidget {
  final Alignment? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip clipBehavior;
  final double innerBorderSize;
  
  final Widget child;

  const TwoBorderContainer({
    Key? key,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none, 
    this.innerBorderSize = 6, 
    required this.child
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      alignment: alignment,
      clipBehavior: clipBehavior,
      color: color,
      decoration: decoration,
      constraints: constraints,
      foregroundDecoration: foregroundDecoration,
      margin: margin,
      transform: transform,
      transformAlignment: transformAlignment,
      child: Container(
        margin: EdgeInsets.all(innerBorderSize),
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(width: 1)
        ),
        child: child,
      ),
    );
  }
  
}