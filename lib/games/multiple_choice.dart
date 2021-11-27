import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/const.dart';

class QuestionSet {
  const QuestionSet({required this.question, required this.options});

  final Question question;
  final List<Option> options;
}

class Question {
  const Question({required this.value, required this.type, required this.key});
  
  final String value;
  final String type;
  final int key;
}

class Option {
  const Option({required this.value, required this.key});

  final String value;
  final int key;
}

typedef OnOptionSelectCallback = Function(Option option);
typedef RoundOverCallback = Function(bool isCorrect); 



class MultipleChoiceGame extends StatefulWidget {
  MultipleChoiceGame({Key? key}) {
    questionSets = _getQuestionSet();
  } 

  late final List<QuestionSet> questionSets;

  List<QuestionSet> _getQuestionSet() {
    return [
      const QuestionSet(options: [ 
          Option(value: "anjay", key: 2), 
          Option(value: "mabar", key: 4),
          Option(value: "ayaya", key: 1),
          Option(value: "mabok", key: 3),
        ],
        question: Question(value: "abc", type: "text", key: 1)),
      const QuestionSet(options: [ 
          Option(value: "gws", key: 2), 
          Option(value: "def", key: 4),
          Option(value: "qwe", key: 1),
          Option(value: "wqr", key: 3),
        ],
        question: Question(value: "mberr", type: "text", key: 2)),
      const QuestionSet(options: [ 
          Option(value: "gws", key: 2), 
          Option(value: "def", key: 4),
          Option(value: "qwe", key: 1),
          Option(value: "wqr", key: 3),
        ],
        question: Question(value: "mberr", type: "text", key: 2)),
      const QuestionSet(options: [ 
          Option(value: "gws", key: 2), 
          Option(value: "def", key: 4),
          Option(value: "qwe", key: 1),
          Option(value: "wqr", key: 3),
        ],
        question: Question(value: "mberr", type: "text", key: 2)),
    ];
  }

  @override
  State<StatefulWidget> createState() => _MultipleChoiceGameState();
}

class _MultipleChoiceGameState extends State<MultipleChoiceGame> {
  int score = 0;

  void _handleOnSelect(bool isCorrect) {
      setState(() {
        if(isCorrect){
          score++;
        } else {
          score--;
        }
      });
      print("current score:" + score.toString());
  }

  Widget _buildRound(BuildContext context, int itemIndex) {
    print("rebuild");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: GameRound(
        question: widget.questionSets[itemIndex].question, 
        options: widget.questionSets[itemIndex].options, 
        mode: GAME_MODE.imageMeaning, 
        onSelect: (bool isCorrect) => _handleOnSelect(isCorrect),)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const  Text('jojo theme'),
      ),
      // body: SafeArea(child:
      //         ListView(
      //           children: 
      //             widget.questionSets.map((QuestionSet questionSet) {
      //               return GameRound(question: questionSet.question, options: questionSet.options, mode: GAME_MODE.imageMeaning , onSelect: (bool isCorrect) => _handleOnSelect(isCorrect),);
      //             }).toList()
      //           ,
      //           scrollDirection: Axis.horizontal,
      //         ),
      //       )
      body: PageView.builder(
            // store this controller in a State to save the carousel scroll position
            controller: PageController(
              viewportFraction: 1,
            ),
            itemCount: widget.questionSets.length,
            itemBuilder: (BuildContext context, int itemIndex) {
              return _buildRound(context, itemIndex);
            },
          ),
      );
    // return const Text('hi');
  }
}

class GameRound extends StatefulWidget  {
  const GameRound({Key? key, required this.question, required this.options, required this.mode, required this.onSelect}) : super(key: key);

  final Question question;
  final List<Option> options;
  final GAME_MODE mode;
  final RoundOverCallback onSelect;

  @override
  State<StatefulWidget> createState() => _GameRoundState();
}

class _GameRoundState extends State<GameRound> with AutomaticKeepAliveClientMixin<GameRound> {
  Option? selected;
  bool gameOver = false;

  void _handleSelect(Option opt) {
    setState(() {
      selected = opt;
      gameOver = true;
    });
    widget.onSelect(opt.key == widget.question.key);
  }

  @override
  bool get wantKeepAlive => true;

  Widget _getQuestionWidget(Question question) {
    if(widget.mode == GAME_MODE.imageMeaning) {
      return Image(
        image: AssetImage('assets/images/kanji/30kr1n.png'),
        height: 300,
        width: 300,  
      );
    } else {
      return Text(question.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;


    return 
    Container( 
      child: Center(
        child: Column(
          children: [
            Center(
              child: _getQuestionWidget(widget.question)
            ),
            Column(
                children: widget.options.map((Option opt) {
                  return GameOption(option: opt, isSelected: selected?.key == opt.key, disabled: gameOver, correctKey: widget.question.key, onSelect: (option) {
                    _handleSelect(opt);
                    print(selected?.value);
                  });
                }).toList(),
            )
          ],
        ),
      ),

      
    );
  }
}

class GameOption extends StatelessWidget {
  const GameOption({Key? key, required this.option, required this.isSelected, required this.disabled, required this.correctKey, required this.onSelect}): super(key: key);

  final Option option;
  final bool isSelected;
  final bool disabled;

  final int correctKey;
  final OnOptionSelectCallback onSelect;

  Color _getBackgroundColor(BuildContext buildContext) {
    
    
    if((disabled || isSelected) && correctKey == option.key) {
      return Colors.green;
    } else if(isSelected) {
      return Colors.red;
    } else if(disabled) {
      return Colors.grey;
    } 
    
    return Colors.white;
  }

  TextStyle? _getTextStyle(BuildContext buildContext) {
    if(isSelected || disabled) {
      return const TextStyle(
      color: Colors.white
    );;
    }
    return const TextStyle(
      color: Colors.black
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => disabled ? null : onSelect(option),
      child: Container(
        color: _getBackgroundColor(context),
        child: Center(
          child: Text(option.value, style: _getTextStyle(context),),),
        width: 180,
        height: 60
      ),
      
    );
  }
}