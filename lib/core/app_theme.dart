import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme() {
  const seed = Color(0xFF993C1D); // terakota
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    scaffoldBackgroundColor: const Color(0xFFFBF8F4),
  );
  final text = GoogleFonts.poppinsTextTheme(base.textTheme);
  return base.copyWith(
    textTheme: text.copyWith(
      headlineSmall: GoogleFonts.baloo2(textStyle: text.headlineSmall, fontWeight: FontWeight.w800),
      titleLarge: GoogleFonts.baloo2(textStyle: text.titleLarge, fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
