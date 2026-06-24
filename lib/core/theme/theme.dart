// lib/core/theme/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    primarySwatch: Colors.indigo,
    brightness: Brightness.light,
    fontFamily: 'Inter',
  );

  static final ThemeData dark = ThemeData(
    primarySwatch: Colors.indigo,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
  );
}
