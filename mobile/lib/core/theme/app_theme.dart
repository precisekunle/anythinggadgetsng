import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF007AFF); // Tech Blue
  static const Color secondaryColor = Color(0xFF333333); // Dark Grey
  static const Color cardBackgroundColor = Color(0xFFFFFFFF); // Clean White
  static const Color scaffoldBackgroundColor = Color(0xFFF5F5F5); // Light Grey

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: secondaryColor,
        displayColor: secondaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: cardBackgroundColor,
        elevation: 0, // Modern flat look, or slight elevation if preferred
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
