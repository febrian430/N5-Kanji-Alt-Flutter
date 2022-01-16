import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/theme.dart';

class ProgressBar extends StatefulWidget {
  const ProgressBar({
    Key? key, 
    required this.current, 
    required this.gain, 
    required this.upperbound, 
    required this.nextUpperbound, 
    required this.onLevelup, 
    this.animate = true
  }) : super(key: key);
  
  final int current;
  final int gain;
  final int upperbound;
  final int? nextUpperbound; 
  final bool animate;

  final Function() onLevelup;

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late int upperbound = widget.upperbound;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
      setState(() {
        
      });
    });
    if(widget.animate){
      animate();
    } 
    super.initState();
  }

  void animate() async {
    controller.value = widget.current/widget.upperbound;
    await controller.animateTo((widget.current+widget.gain)/widget.upperbound, duration: const Duration(seconds: 1));
    if(widget.gain > widget.upperbound) {
      upperbound = widget.nextUpperbound ?? widget.current;
      widget.onLevelup();

      final remaining = widget.gain - widget.upperbound;
      controller.value = widget.nextUpperbound == null ? remaining.toDouble() : 0;

      await controller.animateTo(remaining/upperbound);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                ),
                borderRadius: BorderRadius.zero
              ),
              child: LinearProgressIndicator(
                value: controller.value,
                minHeight: 5,
                backgroundColor: AppColors.cream,
                color: AppColors.secondary,
                semanticsLabel: 'Progress bar',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                EmptyFlex(flex: 1),
                Expanded(
                  flex: 1,
                  child: Text(
                    '+${widget.gain.toString()} exp', 
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),),
                ),

                Expanded(flex: 1, child: Text(upperbound.toString(),
                    textAlign: TextAlign.right,
                  )
                ),
              ],
            )
            // TextButton(
            //   child: Text("test"),
            //   onPressed: () async {
            //     await controller.animateTo(widget.gain/widget.levelupReq, duration: const Duration(milliseconds: 500));
            //     if(widget.gain > widget.levelupReq) {
            //       widget.onLevelup();
            //       controller.value = 0;
            //       final remaining = widget.gain - widget.levelupReq;
            //       await controller.animateTo(remaining/widget.nextLevel);
            //     }
            //   },
            // )
          ],
        ),
      );
  }
}