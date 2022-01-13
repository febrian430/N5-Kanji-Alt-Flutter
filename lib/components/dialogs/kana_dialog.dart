import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/images.dart';

class KanaDialog extends StatelessWidget {
  const KanaDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final size = MediaQuery.of(context).size;
    return Dialog(
      child: Container(
        child: Image.asset(AppImages.kanaChart),
        height: size.height * 0.75,
        width: size.width * 0.75,
      ),
    );
  }

}