import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/theme.dart';

class ProgressBar extends StatefulWidget {
  const ProgressBar({Key? key, required this.from, required this.gain, required this.levelupReq, required this.nextLevel, required this.onLevelup, }) : super(key: key);
  
  final int from;
  final int gain;
  final int levelupReq;
  final int nextLevel; 

  final Function() onLevelup;

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late int upperbound = widget.levelupReq;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
      setState(() {
        
      });
    });
    animate();
    super.initState();
  }

  void animate() async {
    controller.value = widget.from/widget.levelupReq;
    await controller.animateTo((widget.from+widget.gain)/widget.levelupReq, duration: const Duration(seconds: 1));
    
    if(widget.gain > widget.levelupReq) {
      upperbound = widget.nextLevel;
      widget.onLevelup();
      controller.value = 0;
      final remaining = widget.gain - widget.levelupReq;
      await controller.animateTo(remaining/widget.nextLevel);
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
        padding: const EdgeInsets.all(20.0),
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
                minHeight: 8,
                backgroundColor: AppColors.primary,
                color: AppColors.correct,
                semanticsLabel: 'Progress bar',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: SizedBox()),
                Flexible(
                  child: widget.gain == 0 ?
                    SizedBox()
                    :
                    Text('+${widget.gain.toString()} exp', style: TextStyle(fontSize: 14),),),

                Flexible(child: Text(upperbound.toString())),
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