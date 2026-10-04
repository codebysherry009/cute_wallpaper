import 'package:flutter/material.dart';

class AppColors {
  static const pink = Color(0xFFF43F7E);
  static const pinkDark = Color(0xFFE11D68);
  static const pinkSoft = Color(0xFFFFE1EA);
  static const pinkFaint = Color(0xFFFFF1F5);
  static const ink = Color(0xFF1E1B2E);
  static const muted = Color(0xFF8B8797);
  static const bgTop = Color(0xFFFFF9FB);
  static const bgBottom = Color(0xFFFFE4EC);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.pink,
      primary: AppColors.pink,
    ),
    scaffoldBackgroundColor: AppColors.bgTop,
    splashFactory: InkRipple.splashFactory,
  );
}
