import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget  {
  const SubmitButton({Key? key, required this.visible, required this.onTap}) : super(key: key);
  
  final bool visible;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: visible,
        child: ElevatedButton(
          onPressed: onTap, 
          child: const Center(
            child: Text(
              'Submit answers'
            )
          )
        )
      );
  }
}