import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';

class PickDrop extends StatelessWidget {
  PickDrop({Key? key}) : super(key: key);

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
        Option(value: 'rune 2', key: 2.toString()),
      ]);

  @override
  Widget build(BuildContext context) {
    final q = questionSet.question;
    final opts = questionSet.options;
    print("LENGTH: " + opts.length.toString());
    return  Scaffold(
      appBar: AppBar(title: const Text('PICK AND DROP'),),
      body: Center(
        child: Column(
          children: [
            DragTarget<Option>(
              builder: (context, candidateData, rejectedData) {
                return QuestionWidget(value: q.value, key: key, answerKey: q.key.toString(), isImage: true);
              },
              onWillAccept: (opt) => opt?.key == q.key,
              onAccept: (opt) {
                print("ACCEPTED");

              },
            ),  
            Container(height: 30, decoration: BoxDecoration(border: Border.all(width: 3)),),
            Expanded(
              child: Container(
                height: 200,
                child: GridView.count(
                    padding: const EdgeInsets.all(20),
                    crossAxisCount: 3,
                    crossAxisSpacing: 30,
                    mainAxisSpacing: 30,
                    physics: const NeverScrollableScrollPhysics(),
                    primary: false,
                    children: opts.map((opt) {
                      return Draggable<Option>(
                        data: opt,
                        child: Container(
                          height: 50,
                          width: 50,
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
                          height: 97,
                          width: 97,
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
                        
                        childWhenDragging: const SizedBox(
                          height: 50, 
                          width: 50,
                        )
                      );
                    }).toList()
                  )
                )
            )
          ],
        ),
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