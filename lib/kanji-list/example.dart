import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example.dart';

class ExampleContainer extends StatelessWidget {
  final Example example;

  const ExampleContainer({Key? key, required this.example}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1
        )
      ),
      child: Column(
        children: [
          Flexible(
            flex: 2, 
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 1))
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(example.rune),
                      Text('( ${example.spelling.join('')} )'),
                    ],
                  )
                );
              }
            )
          ),
          Expanded(
            flex: 4,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                child: Image.asset(
                  KANJI_IMAGE_FOLDER+example.image,
                  fit: BoxFit.contain,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1))
                ),
              ),
            )
          ),
          Expanded(
            flex: 1,
            child: Text(example.meaning, textAlign: TextAlign.center,),
          )
        ],
      ),
    );
  }
}