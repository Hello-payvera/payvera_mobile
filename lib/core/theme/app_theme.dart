import 'package:flutter/material.dart';

class AppTheme {
  static const Color green = Color(0xFF006B4F);
  static const Color gold = Color(0xFFD4AF37);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF111827);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: green,
      primary: green,
      secondary: gold,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: green,
      foregroundColor: white,
      centerTitle: true,
    ),
  );
}