import 'package:flutter/material.dart';

/// PhotoKids Studio Color Palette
/// Fröhlich, modern, warm und kindgerecht mit harmonischen Farbverläufen
class AppColors {
  // Primary Palette
  static const Color pinkPrimary = Color(0xFFFF5277);
  static const Color pinkLight = Color(0xFFFF8FA5);
  static const Color pinkDark = Color(0xFFC7284F);
  static const Color pinkSoft = Color(0xFFFFEEF2);

  // Secondary Palette
  static const Color turquoiseSecondary = Color(0xFF00C4B4);
  static const Color turquoiseLight = Color(0xFF64FFDA);
  static const Color turquoiseDark = Color(0xFF00897B);
  static const Color turquoiseSoft = Color(0xFFE0F7F6);

  // Accent Colors
  static const Color yellowAccent = Color(0xFFFFC107);
  static const Color yellowLight = Color(0xFFFFE082);
  static const Color yellowDark = Color(0xFFFFA000);
  static const Color yellowSoft = Color(0xFFFFF9E6);

  static const Color purpleAccent = Color(0xFF9C27B0);
  static const Color purpleLight = Color(0xFFCE93D8);
  static const Color purpleDark = Color(0xFF6A1B9A);
  static const Color purpleSoft = Color(0xFFF3E5F5);

  // Background Gradients & Colors
  static const Color bgLight = Color(0xFFFFFBFD);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgDark = Color(0xFF191421);
  static const Color bgCardDark = Color(0xFF261F33);

  // Playful Linear Gradients
  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFFF5277), Color(0xFFFF7597)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient turquoiseGradient = LinearGradient(
    colors: [Color(0xFF00C4B4), Color(0xFF26E5D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [Color(0xFFFFB300), Color(0xFFFFD54F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rainbowGradient = LinearGradient(
    colors: [
      Color(0xFFFF5277),
      Color(0xFFFF9800),
      Color(0xFFFFEB3B),
      Color(0xFF4CAF50),
      Color(0xFF00BCD4),
      Color(0xFF9C27B0),
    ],
  );

  static const LinearGradient softBgGradient = LinearGradient(
    colors: [Color(0xFFFFFBFD), Color(0xFFF3F7FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF2196F3);
  static const Color warning = Color(0xFFFF9800);

  // Drawing Palette
  static const List<Color> drawingPalette = [
    Color(0xFFFF1744), // Rot
    Color(0xFFFF5277), // Pink
    Color(0xFFFF9100), // Orange
    Color(0xFFFFD600), // Gelb
    Color(0xFF00E676), // Hellgrün
    Color(0xFF00B0FF), // Hellblau
    Color(0xFF651FFF), // Lila
    Color(0xFFD500F9), // Magenta
    Color(0xFF8D6E63), // Braun
    Color(0xFF212121), // Schwarz
    Color(0xFFFFFFFF), // Weiß
  ];
}
