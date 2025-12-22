import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import 'app_colors.dart';

/// General styling utility for theme-aware colors and styles
class AppStyles {
  // Background colors
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.surface;
  }

  static Color card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkCard
        : AppColors.cardColor;
  }

  // Text colors
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
  }

  static Color textMuted(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted;
  }

  // Border colors
  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBorder
        : AppColors.borderColor;
  }

  // Header container decoration
  static BoxDecoration headerDecoration(BuildContext context) {
    return BoxDecoration(
      color: surface(context).withOpacity(0.8),
      border: Border(
        bottom: BorderSide(
          color: border(context),
          width: 1,
        ),
      ),
    );
  }

  // Navigation bar decoration
  static BoxDecoration navBarDecoration(BuildContext context) {
    return BoxDecoration(
      color: surface(context).withOpacity(0.9),
      border: Border(
        top: BorderSide(
          color: border(context),
          width: 1,
        ),
      ),
    );
  }

  // Card decoration
  static BoxDecoration cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: card(context).withOpacity(0.5),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: border(context),
        width: 1,
      ),
      boxShadow: isDark ? null : [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Text field decoration
  static BoxDecoration textFieldDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.glassBackground
          : Colors.white.withOpacity(0.8),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: border(context),
        width: 1,
      ),
    );
  }

  // Tab decoration
  static BoxDecoration tabDecoration(BuildContext context, bool isSelected) {
    return BoxDecoration(
      color: isSelected
          ? AppColors.primaryGreen
          : card(context).withOpacity(0.5),
      borderRadius: BorderRadius.circular(8),
    );
  }

  // Text styles
  static TextStyle headerTitle(BuildContext context, bool isAmharic) {
    return TextStyle(
      color: textPrimary(context),
      fontSize: isAmharic ? 20 : 24,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle subtitle(BuildContext context) {
    return TextStyle(
      color: textMuted(context),
      fontSize: 14,
    );
  }

  static TextStyle navLabel(BuildContext context, bool isSelected) {
    return TextStyle(
      color: isSelected ? AppColors.primaryGreen : textSecondary(context),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle tabText(BuildContext context, bool isSelected) {
    return TextStyle(
      color: isSelected ? Colors.white : textSecondary(context),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle legendText(BuildContext context) {
    return TextStyle(
      color: textSecondary(context),
      fontSize: 12,
    );
  }

  static TextStyle insightTitle(BuildContext context) {
    return TextStyle(
      color: textSecondary(context),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle insightValue(BuildContext context) {
    return TextStyle(
      color: textPrimary(context),
      fontSize: 24,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle insightSubtitle(BuildContext context) {
    return TextStyle(
      color: textMuted(context),
      fontSize: 10,
    );
  }

  // Input decoration for text fields
  static InputDecoration textFieldInputDecoration(
    BuildContext context,
    String hintText,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: textMuted(context),
        fontSize: 16,
      ),
      prefixIcon: Icon(
        icon,
        color: textMuted(context),
        size: 20,
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  // Text field label style
  static TextStyle textFieldLabel(BuildContext context) {
    return TextStyle(
      color: textSecondary(context),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
  }

  // Button styles
  static ButtonStyle primaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static BoxDecoration primaryButtonDecoration(BuildContext context) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primaryGreen,
          AppColors.primaryGreen.withOpacity(0.8),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
    );
  }

  static TextStyle buttonText(BuildContext context) {
    return const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle linkText(BuildContext context) {
    return TextStyle(
      color: AppColors.primaryGreen,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
  }

  // Chart grid lines
  static FlLine chartGridLine(BuildContext context) {
    return FlLine(
      color: border(context),
      strokeWidth: 1,
      dashArray: [5, 5],
    );
  }
}
