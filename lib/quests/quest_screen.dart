import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class QuestScreen extends StatefulWidget {
  
  static const route = "/quests";
  static const name = "Quest Screen";
  
  @override
  State<StatefulWidget> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {

  int listIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Center(child: _ProgressContainer()),
              _SelectBar(onTap: (int index) {
                setState(() {
                  listIndex = index;
                });
              }),
              _QuestList(index: listIndex,)
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      height: size.height*0.125,
      width: size.width*0.8,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(child: Text("Level"),),
          Center(child: Text("Progress bar here"),)
        ],
      ),
    );
  }
}

class _SelectBar extends StatelessWidget {
  final Function(int index) onTap;
  const _SelectBar({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      height: size.height*0.1,
      width: size.width*0.8,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () {
              onTap(0);
            }, 
            child: Text("Mastery")
          ),
          TextButton(
            onPressed: () {
              onTap(1);
            }, 
            child: Text("Practice")
          ),
          TextButton(
            onPressed: () {
              onTap(2);
            }, 
            child: Text("Quiz")
          ),
        ],
      ),
    );
  }
}

class _QuestList extends StatelessWidget {
  const _QuestList({Key? key, this.index = 0}) : super(key: key);
  
  final int index;

  Widget _mastery() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return SizedBox(child: Text("Mastery " + index.toString()), height: 150);
      }
    );
    
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      height: size.height*0.6,
      width: size.width*0.8,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
        )
      ),
      child: IndexedStack(
        index: index,
        children: [
          _mastery(),
          Text("Practice"),
          Text("Quiz"),
          Text("Learn"),
        ],
      ),
    );
  }
}
