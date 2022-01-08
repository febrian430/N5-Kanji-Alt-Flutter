import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/color_hex.dart';

class AppButtonTheme {
  static final Color buttonColor = AppColors.primary;
  static final Color buttonOutline = HexColor.fromHex("3f3f3f");
}

class AppColors {
  static final Color primary = HexColor.fromHex("fefbe7");
  static final Color secondary = HexColor.fromHex("f8b444");
  static final Color correct = HexColor.fromHex("6DC063");
  static final Color wrong = HexColor.fromHex("DE7162");
  static final Color selected = HexColor.fromHex("F0E9D0");
}