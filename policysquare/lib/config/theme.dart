// # App theme and styling

// lib/config/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF005A9C), // A professional blue
      primary: const Color(0xFF005A9C),
      secondary: const Color(0xFF00AEEF),
      surface: Colors.white,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF4F7FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF005A9C),
      unselectedItemColor: Colors.grey,
    ),
  );
}
