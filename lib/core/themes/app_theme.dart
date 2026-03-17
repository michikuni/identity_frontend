import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF0047AB);
  static const backgroundColor = Color(0xFFF0F4F8);
  static const textPrimary = Color(0xFF1A202C);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
  );
}