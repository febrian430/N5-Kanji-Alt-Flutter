import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VisibleButton extends StatelessWidget  {
  const VisibleButton({Key? key, required this.visible, required this.onTap, required this.title}) : super(key: key);
  
  final String title;
  final bool visible;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: TextButton(
        onPressed: onTap, 
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 2)
          ),
          child:  Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),
            )
          ),
        )
    );
  }
}