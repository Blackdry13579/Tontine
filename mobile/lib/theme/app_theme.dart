import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Couleurs principales extraites du code HTML
  static const Color primaryGold = Color(0xFFC9A326);
  static const Color emeraldDark = Color(0xFF0B3D2E);
  static const Color cream = Color(0xFFF5F5DC);
  static const Color creamLight = Color(0xFFF5F0E1);
  static const Color textDark = Color(0xFF201D12);
  static const Color grayText = Color(0xFF867E65);
  
  // Gradients dorés
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE6C667),
      Color(0xFFC9A326),
      Color(0xFFA6821D),
    ],
  );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: emeraldDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGold,
        primary: primaryGold,
        onPrimary: emeraldDark,
        secondary: primaryGold,
        onSecondary: emeraldDark,
        surface: emeraldDark,
        onSurface: cream,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme().apply(
        bodyColor: cream,
        displayColor: primaryGold,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: emeraldDark,
          elevation: 0,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGold,
          side: const BorderSide(color: Color(0x99C9A326), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
        labelStyle: const TextStyle(color: primaryGold),
        hintStyle: TextStyle(color: cream.withValues(alpha: 0.4)),
      ),
    );
  }

  // Variante claire pour les écrans d'Auth
  static ThemeData get lightTheme {
    final base = theme;
    return base.copyWith(
      scaffoldBackgroundColor: creamLight,
      colorScheme: base.colorScheme.copyWith(
        surface: Colors.white,
        onSurface: textDark,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E3DC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E3DC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
        labelStyle: const TextStyle(color: textDark),
        hintStyle: const TextStyle(color: grayText),
      ),
    );
  }
}
