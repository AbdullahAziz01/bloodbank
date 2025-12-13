import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration inspired by SadaPay design
/// Clean, minimal, with soft gradients and rounded UI

class AppTheme {
  // Color palette - Light Mode
  static const Color primaryRed = Color(0xFFE83E3E);
  static const Color gradientStart = Color(0xFFFF4D6D);
  static const Color gradientEnd = Color(0xFFFF7A59);
  static const Color background = Color(0xFFF8F9FB);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);

  // Color palette - Dark Mode
  // Color palette - Dark Mode
  static const Color darkBackground = Color(0xFF000000); // Pure Black
  static const Color darkCardBackground = Color(0xFF121212); // Slightly lighter for cards to distinguish from black bg
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkBorderColor = Color(0xFF333333);

  // Gradient
  static LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  // Text styles
  static TextStyle get heading1 => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle get heading2 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get heading3 => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textSecondary,
        height: 1.4,
      );

  static TextStyle get buttonText => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  // Theme data - Light Mode
  // Theme data - Light Mode
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white, // Explicit White
        colorScheme: ColorScheme.light(
          primary: primaryRed,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSurface: Colors.black, // Black Text
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: borderColor, width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Or Red if preferred, but keeping transparent for gradient
          elevation: 0,
          foregroundColor: Colors.white, // White text/icons on AppBar always
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryRed, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: TextStyle(color: textSecondary),
          hintStyle: TextStyle(color: textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: buttonText,
          ),
        ),
        textTheme: TextTheme(
          displayLarge: heading1.copyWith(color: Colors.black),
          displayMedium: heading2.copyWith(color: Colors.black),
          displaySmall: heading3.copyWith(color: Colors.black),
          bodyLarge: bodyLarge.copyWith(color: Colors.black),
          bodyMedium: bodyMedium.copyWith(color: textSecondary),
          bodySmall: bodySmall.copyWith(color: textSecondary),
        ),
      );

  // Theme data - Dark Mode
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000), // Pure Black strictly
        colorScheme: ColorScheme.dark(
          primary: primaryRed,
          surface: const Color(0xFF1A1A1A), // Dark Grey Surface
          onPrimary: Colors.white,
          onSurface: Colors.white, // White Text
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1A1A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: const Color(0xFF333333), width: 1), // Dark border
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Identical to Light Mode
          elevation: 0,
          foregroundColor: Colors.white, // Identical to Light Mode
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: const Color(0xFF333333)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: const Color(0xFF333333)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryRed, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: const TextStyle(color: Color(0xFFB0B0B0)),
          hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: buttonText,
          ),
        ),
        textTheme: TextTheme(
          displayLarge: heading1.copyWith(color: Colors.white),
          displayMedium: heading2.copyWith(color: Colors.white),
          displaySmall: heading3.copyWith(color: Colors.white),
          bodyLarge: bodyLarge.copyWith(color: Colors.white),
          bodyMedium: bodyMedium.copyWith(color: const Color(0xFFB0B0B0)), // Light Grey
          bodySmall: bodySmall.copyWith(color: const Color(0xFFB0B0B0)),
        ),
      );
}

