import 'package:flutter/material.dart';

final lightThemeData = ThemeData(
  scaffoldBackgroundColor: const Color(0xFFFFE7D3),
  fontFamily: fontName,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFE7D3),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: const Color(0xFF060575),
    selectionColor: Colors.teal.shade100,
    selectionHandleColor: const Color(0xFF060575),
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFFFE7D3),
    brightness: Brightness.light,
    primary: const Color(0xFFFFE7D3),
    secondary: const Color(0xFF060575),
    tertiary: const Color(0xFF5584b2),
    surface: const Color(0xff9dbdd5),
    background: const Color(0xFFFFFFFF)
  ),
  useMaterial3: true,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF5584b2),
    selectedItemColor: Colors.white,
    unselectedItemColor: Color(0xFFB3B3B3),
  ),
);

const fontName = 'YanoneKaffeesatz';

final darkThemeData = ThemeData(
  scaffoldBackgroundColor: const Color(0xFF050505),
  fontFamily: fontName,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF050505),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFF060575),
    selectionColor: Colors.white30,
    selectionHandleColor: Color(0xFF060575),
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF050505),
    brightness: Brightness.dark,
    primary: const Color(0xFFFFE7D3),
    secondary: const Color(0xFFFFFFFF),
    tertiary: const Color(0xFF5584b2),
    surface: const Color(0xFF6B6A94),
    background: const Color(0xFFFFFFFF)
  ),
  useMaterial3: true,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF5584b2),
    selectedItemColor: Colors.white,
    unselectedItemColor: Color(0xFFB3B3B3),
  ),
);