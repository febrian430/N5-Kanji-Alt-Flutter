import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';

class PickDrop extends StatelessWidget {
  PickDrop({Key? key, required this.chapter, required this.mode}) : super(key: key);

  static const route = '/game/pick-drop';
  static const name = 'Pick and Drop';

  final int chapter;
  final GAME_MODE mode;


  final QuestionSet questionSet = QuestionSet(
      question: Question(
        value: '30kr1n.png', 
        isImage: true, 
        key: 1.toString()), 
      options: [
        Option(value: 'rune 3', key: 3.toString()),
        Option(value: 'rune 1', key: 1.toString()),
        Option(value: 'rune 2', key: 2.toString()),
        Option(value: 'rune 3', key: 3.toString()),
        Option(value: 'rune 1', key: 1.toString()),
        Option(value: 'rune 2', key: 2.toString()),
        Option(value: 'rune 3', key: 3.toString()),
        Option(value: 'rune 1', key: 1.toString()),
      ]);

  Widget _optionsByGridView(BuildContext context, List<Option> opts) {
    final size = MediaQuery.of(context).size;

    return Expanded(
                child: Container(
                  height: 200,
                  child: GridView.count(
                      padding: const EdgeInsets.all(15),
                      crossAxisCount: 4,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      children: opts.map((opt) {
                        return _renderOption(context, opt);
                      }).toList()
                    )
                  )
              );
  }

  Widget _renderOption(BuildContext context, Option opt) {
    final size = MediaQuery.of(context).size;

    return Draggable<Option>(
            data: opt,
            maxSimultaneousDrags: 1,
            child: Container(
                height: size.height*0.115,
                width: size.height*0.115,
                decoration: BoxDecoration(border: Border.all(width: 3)),
                child: Center(
                  child: Text(
                  opt.value,  
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    ),
                  )
                )
              ),
              feedback: Container(
                height: size.height*0.115,
                width: size.height*0.115,
                decoration: BoxDecoration(border: Border.all(width: 3)),
                child: Center(
                  child: Text(
                  opt.value,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    decoration: TextDecoration.none
                    ),
                  )
                )
              ),
               
              childWhenDragging: SizedBox(
                height: size.height*0.115,
                width: size.height*0.115,
              )
            );
  }

  Widget _optionsByColumn(BuildContext context, List<Option> opts) {
    final screen = MediaQuery.of(context).size;

    return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: opts.take(4).map((opt) {
                return _renderOption(context, opt);
              }).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: opts.skip(4).map((opt) {
                return _renderOption(context, opt);
              }).toList(),
            ),
          ]
        );
  }

  @override
  Widget build(BuildContext context) {
    final q = questionSet.question;
    final opts = questionSet.options;

    final screen = MediaQuery.of(context).size;

    return  Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            
            children: [
              Container(
                height: screen.height*0.5,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: DragTarget<Option>(
                    builder: (context, candidateData, rejectedData) {
                      return QuestionWidget(value: q.value, key: key, answerKey: q.key.toString(), isImage: true);
                    },
                    onWillAccept: (opt) => opt?.key == q.key,
                    onAccept: (opt) {
                      print("ACCEPTED");
                    },
                  )
                ),
              ),  
              SizedBox(height: screen.height*0.1,),
              Container(
                height: screen.height*0.3,
                child: _optionsByColumn(context, opts)
              )
            ],
          ),
        )
      )
    );
  }
}

class QuestionWidget extends StatelessWidget {
  const QuestionWidget({Key? key, required this.value, required this.isImage, required this.answerKey}) : super(key: key);
  
  final String value;
  final bool isImage;
  final String answerKey;

  @override
  Widget build(BuildContext context) {
    if(isImage) {
      return Container(
          child: Image(
            image: AssetImage(KANJI_IMAGE_FOLDER + value),
            height: 250,
            width: 250,
            fit: BoxFit.fill,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: 3,
              color: Colors.black
            )
          ),
        );
    } else {
      return Container(
        child: Center(child: Text(value)),
        height: 250,
        width: 250,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 3
          )
        ),
      );
    }
  }
}

class OptionWidget extends StatelessWidget {
  const OptionWidget({Key? key, required this.value, required this.answerKey}) : super(key: key);
  
  final String value;
  final int answerKey;

   @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
          child: Text(
            value,
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            )),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 3
          )
        ),
      );
  }
}