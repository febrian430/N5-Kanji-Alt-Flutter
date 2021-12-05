import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/menu_screens/result_screen.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/pick-drop/repo.dart';
import 'package:kanji_memory_hint/route_param.dart';

//TODO: wrong count, correct result page, 
class PickDrop extends StatefulWidget {
  PickDrop({Key? key, required this.chapter, required this.mode}) : super(key: key);

  static const route = '/game/pick-drop';
  static const name = 'Pick and Drop';

  final int chapter;
  final GAME_MODE mode;

  Future<List<QuestionSet>> _getQuestionSets() {
    return getPickDropQuestionSets(10, chapter, mode);
  }

  @override
  State<StatefulWidget> createState() => _PickDropState();
  
}

class _PickDropState extends State<PickDrop> {

  var sets;
  int index = 0;
  int wrongAttempts = 0;

  late int total;

  @override
  void initState() {
    super.initState();
    sets = widget._getQuestionSets();
  }


  void _handleOnDrop(bool isCorrect) {
    print(isCorrect);
    setState(() {
      if (index < total-1) {
        index++;  
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final screen = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: sets,
          builder: (context, AsyncSnapshot<List<QuestionSet>> snapshot){
            if(snapshot.hasData){
              total = snapshot.data!.length;
              var set = snapshot.data!.elementAt(index);
              return PickDropRound(question: set.question, options: set.options, onDrop: _handleOnDrop, isLast: index == total-1,);
            } else {
              return Center(child: Text("Loading"),);
            }
          }
        )
      )
    );
  }
}

typedef OnDropCallback = Function(bool isCorrect);

class PickDropRound extends StatefulWidget {
  const PickDropRound({Key? key, required this.question, required this.options, required this.onDrop, required this.isLast}) : super(key: key);

  final Question question;
  final List<Option> options;
  final OnDropCallback onDrop;
  final bool isLast;

  @override
  State<StatefulWidget> createState() => _PickDropRoundState();
}

class _PickDropRoundState extends State<PickDropRound> {

  bool isCorrect = false;

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
                        children: widget.options.map((opt) {
                          return _renderOption(context, opt);
                        }).toList()
                      )
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
    final screen = MediaQuery.of(context).size;

    return Center(
          child: Column(
            
            children: [
              Container(
                height: screen.height*0.5,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: DragTarget<Option>(
                    builder: (context, candidateData, rejectedData) {
                      return _QuestionWidget(value: widget.question.value, answerKey: widget.question.key.toString(), isImage: true);
                    },
                    onWillAccept: (opt) {
                     return opt?.key == widget.question.key;
                    },
                    onAccept: (opt) {
                      widget.onDrop(opt.key == widget.question.key);
                    },

                  )
                ),
              ),  
              SizedBox(height: screen.height*0.07,),
              Container(
                height: screen.height*0.3,
                child: _optionsByColumn(context, widget.options)
              ),
              Visibility(
                visible: widget.isLast,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, ResultScreen.route, 
                      arguments: ResultParam(wrongCount: 5, decreaseFactor: 100));
                  }, 
                  child: const Center(
                    child: Text(
                      'See result'
                    )
                  )
                )
              )
            ],
          ),
        );
  }
}

class _QuestionWidget extends StatelessWidget {
  const _QuestionWidget({Key? key, required this.value, required this.isImage, required this.answerKey}) : super(key: key);
  
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

class _OptionWidget extends StatelessWidget {
  const _OptionWidget({Key? key, required this.value, required this.answerKey}) : super(key: key);
  
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