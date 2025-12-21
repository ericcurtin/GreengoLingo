import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primaryGreen = Color(0xFF58CC02);
  static const Color secondaryGreen = Color(0xFF89E219);
  static const Color darkGreen = Color(0xFF458800);

  // Accent colors
  static const Color accentBlue = Color(0xFF1CB0F6);
  static const Color accentPurple = Color(0xFFA560E8);
  static const Color accentOrange = Color(0xFFFF9600);
  static const Color accentPink = Color(0xFFFF86D0);
  static const Color accentYellow = Color(0xFFFFD900);

  // Feedback colors
  static const Color success = Color(0xFF58CC02);
  static const Color error = Color(0xFFFF4B4B);
  static const Color warning = Color(0xFFFFAA00);
  static const Color info = Color(0xFF1CB0F6);

  // Correct/Incorrect
  static const Color correct = Color(0xFF58CC02);
  static const Color correctLight = Color(0xFFD7FFB8);
  static const Color incorrect = Color(0xFFFF4B4B);
  static const Color incorrectLight = Color(0xFFFFDFDF);

  // Background colors
  static const Color backgroundLight = Color(0xFFF7F7F7);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF232340);

  // Text colors
  static const Color textDark = Color(0xFF3C3C3C);
  static const Color textMedium = Color(0xFF777777);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFAFAFAF);

  // Progress colors
  static const Color progressBackground = Color(0xFFE5E5E5);
  static const Color progressBackgroundDark = Color(0xFF3D3D5C);

  // XP colors
  static const Color xpGold = Color(0xFFFFD900);
  static const Color xpGoldDark = Color(0xFFE6C300);

  // Streak colors
  static const Color streakOrange = Color(0xFFFF9600);
  static const Color streakRed = Color(0xFFFF4B4B);

  // Level colors (matching CEFR levels)
  static const Color levelA1 = Color(0xFF4CAF50); // Green
  static const Color levelA2 = Color(0xFF8BC34A); // Light Green
  static const Color levelB1 = Color(0xFFFFC107); // Amber
  static const Color levelB2 = Color(0xFFFF9800); // Orange
  static const Color levelC1 = Color(0xFFF44336); // Red
  static const Color levelC2 = Color(0xFF9C27B0); // Purple

  // Flag colors (for language selection)
  static const Color flagPortugal = Color(0xFF006600);
  static const Color flagBrazil = Color(0xFF009B3A);
  static const Color flagUSA = Color(0xFF3C3B6E);
  static const Color flagUK = Color(0xFF012169);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, secondaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [xpGold, xpGoldDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient streakGradient = LinearGradient(
    colors: [streakOrange, streakRed],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Get color for CEFR level
  static Color getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return levelA1;
      case 'A2':
        return levelA2;
      case 'B1':
        return levelB1;
      case 'B2':
        return levelB2;
      case 'C1':
        return levelC1;
      case 'C2':
        return levelC2;
      default:
        return primaryGreen;
    }
  }
}
