import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/components/buttons/button.dart';

Widget AppBackButton(BuildContext context){
  return AppButton(onTap: () {
    Navigator.pop(context);
  });
}