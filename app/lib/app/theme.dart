import 'package:flutter/material.dart';

const _bg = Color(0xFF0B1020);
const _surface = Color(0xFF131C33);
const _primary = Color(0xFF7C8CFF);
const _accent = Color(0xFF5EEAD4);

final ThemeData genesisCoreDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _bg,
  colorScheme: const ColorScheme.dark(
    primary: _primary,
    secondary: _accent,
    surface: _surface,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: _bg,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
  ),
  cardTheme: const CardThemeData(
    color: _surface,
    elevation: 0,
    margin: EdgeInsets.symmetric(vertical: 8),
  ),
  useMaterial3: true,
);
