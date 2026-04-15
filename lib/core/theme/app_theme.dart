import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1FA2D6);
  static const Color darkBlue = Color(0xFF1C8EC2);
  static const Color lightBackground = Color(0xFFF2F2F2);

  static const Color success = Colors.green;
  static const Color danger = Colors.red;
  static const Color textGrey = Colors.grey;

  // THEME GLOBAL
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: lightBackground,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
    ),

    //  APPBAR
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    //  BOTONES
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    //  TEXTOS
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );
}