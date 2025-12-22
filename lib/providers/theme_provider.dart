import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/constants.dart';
import '../core/theme/app_colors.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(AppConstants.themeKey) ?? true;
    state = isDark ? ThemeMode.dark : ThemeMode.light;

    // Update AppColors static flag immediately
    AppColors.isDarkMode = isDark;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await prefs.setBool(AppConstants.themeKey, newMode == ThemeMode.dark);
    state = newMode;

    // Update AppColors static flag
    AppColors.isDarkMode = newMode == ThemeMode.dark;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.themeKey, mode == ThemeMode.dark);
    state = mode;

    // Update AppColors static flag
    AppColors.isDarkMode = mode == ThemeMode.dark;
  }
}
