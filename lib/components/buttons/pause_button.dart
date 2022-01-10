import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/dialogs/pause_dialog.dart';
import 'package:kanji_memory_hint/icons.dart';

class PauseButton extends StatelessWidget {
  final Function() onRestart;
  final Function() onContinue;
  final Function() onPause;
  final bool withChart;

  const PauseButton({Key? key, required this.onRestart, required this.onContinue, required this.onPause, this.withChart = true}) : super(key: key);

  Widget buildDialog(BuildContext context) {
    return PauseDialog(
      onRestart: onRestart, 
      onContinue: onContinue,
      withKanaChart: withChart,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return TextButton(
      onPressed: () {
        onPause();
        showDialog(context: context, builder: buildDialog);
      },
      style: TextButton.styleFrom(
        side: BorderSide.none,
        backgroundColor: Colors.transparent
      ),
      child: Container(
        child: Image.asset(
          AppIcons.pause,
          height: 25,
          width: 25,
          // fit: BoxFit.scaleDown,
        ),
        height: size.width*0.075,
        width: size.width*0.075,
      ),
    );
  }

}