// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: GoogleFonts.roboto().fontFamily,
    scaffoldBackgroundColor: const Color(0xFFF8F8FA),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF007AFF),
      secondary: Color(0xFFE5E5EA),
      surface: Color(0xFFF0F0F5),
      onPrimary: Colors.white,
      onSurface: Colors.black,
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black87)),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: GoogleFonts.roboto().fontFamily,
    scaffoldBackgroundColor: const Color(0xFF1C1C1E),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0A84FF),
      secondary: Color(0xFF3A3A3C),
      surface: Color(0xFF2C2C2E),
      onPrimary: Colors.white,
      onSurface: Colors.white70,
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white70)),
  );
}
