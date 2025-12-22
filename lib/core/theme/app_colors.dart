import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Simple Green Theme
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenLight = Color(0xFF81C784);
  static const Color primaryGreenDark = Color(0xFF388E3C);

  // Background Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Card Colors
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color darkCard = Color(0xFF2A2A2A);

  // Text Colors
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightTextMuted = Color(0xFF999999);

  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextMuted = Color(0xFF808080);

  // Sensor Colors - Simplified
  static const Color soilMoisture = Color(0xFF2196F3);
  static const Color temperature = Color(0xFFFF5722);
  static const Color humidity = Color(0xFF00BCD4);
  static const Color lightSensor = Color(0xFFFFC107);
  static const Color battery = Color(0xFF4CAF50);
  static const Color waterUsed = Color(0xFF9C27B0);

  // Border and Glass Effects
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color darkBorder = Color(0xFF404040);
  static const Color glassBackground = Color(0x1FFFFFFF);
  static const Color glassBorder = Color(0x26FFFFFF);

  // Helper getters for theme-aware colors
  static Color get primaryColor => primaryGreen;
  static Color get textPrimary => isDarkMode ? darkTextPrimary : lightTextPrimary;
  static Color get textSecondary => isDarkMode ? darkTextSecondary : lightTextSecondary;
  static Color get textMuted => isDarkMode ? darkTextMuted : lightTextMuted;
  static Color get background => isDarkMode ? darkBackground : lightBackground;
  static Color get surface => isDarkMode ? darkSurface : lightBackground;
  static Color get cardColor => isDarkMode ? darkCard : lightCard;
  static Color get borderColor => isDarkMode ? darkBorder : lightBorder;

  // Static flag to determine theme (will be set by theme provider)
  static bool isDarkMode = false;

  // Gradients
  static LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, primaryGreenLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
