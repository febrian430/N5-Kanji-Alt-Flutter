import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NextQuizRoundButton extends StatelessWidget {
  
  final Function() onTap;
  final bool visible;

  const NextQuizRoundButton({Key? key, required this.onTap, required this.visible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: visible,
        child: ElevatedButton(
          onPressed: onTap, 
          child: const Center(
            child: Text(
              'Start Jumble Quiz Round'
            )
          )
        )
      );
  }
}