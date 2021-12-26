import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/components/buttons/button.dart';

Widget AppBackButton(BuildContext context){
  return AppButton(title: "Back", onTap: () {
    Navigator.pop(context);
  });
}