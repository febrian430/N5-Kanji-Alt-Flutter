import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/select_button.dart';
import 'package:kanji_memory_hint/result_screen/practice.dart';
import 'package:kanji_memory_hint/route_param.dart';

class ResultButton extends StatelessWidget  {
  const ResultButton({Key? key, required this.visible, required this.param}) : super(key: key);
  
  final bool visible;
  final ResultParam param;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: SelectButton(
        onTap: () {
          Navigator.pushNamed(context, ResultScreen.route, 
            arguments: param
          );
        }, 
        title: 'Result' 
      )
    );
  }
}