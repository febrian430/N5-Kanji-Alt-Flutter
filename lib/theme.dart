import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/color_hex.dart';
import 'package:kanji_memory_hint/const.dart';

class AppButtonTheme {
  static final Color buttonColor = AppColors.primary;
  static final Color buttonOutline = HexColor.fromHex("3f3f3f");
}

class AppColors {
  static final Color primary = HexColor.fromHex("fefbe7");
  static final Color secondary = HexColor.fromHex("f8b444");
  static final Color correct = HexColor.fromHex("6DC063");
  static final Color wrong = HexColor.fromHex("DE7162");
  static final Color selected = HexColor.fromHex("d9c08d");
  static final Color teal = HexColor.fromHex("71cac4");
  static final Color purple = HexColor.fromHex("D083A8");
  static final Color white = HexColor.fromHex("FFFBE6");
  static final Color darkGreen = HexColor.fromHex("4DB784");
}

class AppBackgrounds {
  static final String common = APP_IMAGE_FOLDER + 'main_menu.png';
  static final String quiz = APP_IMAGE_FOLDER + 'bg_quiz.png';
  static final String practice = APP_IMAGE_FOLDER + 'bg_practice.png';
}