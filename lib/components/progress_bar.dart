import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressBar extends StatefulWidget {
  const ProgressBar({Key? key, required this.from, required this.to, required this.total, required this.nextLevel, required this.onLevelup, }) : super(key: key);
  
  final int from;
  final int to;
  final int total;
  final int nextLevel; 

  final Function() onLevelup;

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
      setState(() {
        
      });
    });
    controller.value = widget.from/widget.total;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10)
              ),
              child: LinearProgressIndicator(
                value: controller.value,
                minHeight: 6,
                color: Colors.green,
                semanticsLabel: 'Progress bar',
              ),
            ),
            TextButton(
              child: Text("test"),
              onPressed: () async {
                
                await controller.animateTo(widget.to/widget.total, duration: const Duration(milliseconds: 500));
                if(widget.to > widget.total) {
                  widget.onLevelup();
                  controller.value = 0;
                  final remaining = widget.to - widget.total;
                  await controller.animateTo(remaining/widget.nextLevel);
                }
                
              },
            )
          ],
        ),
      ),
    );
  }
}