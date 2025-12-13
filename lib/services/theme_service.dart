import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Service for Dark Mode Management
/// Uses SharedPreferences to persist theme preference
class ThemeService {
  static const String _themeKey = 'isDarkMode';

  /// Get current theme preference
  Future<bool> isDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_themeKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Set theme preference
  Future<void> setDarkMode(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDark);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<bool> toggleTheme() async {
    final current = await isDarkMode();
    await setDarkMode(!current);
    return !current;
  }
}

// Global theme notifier
final ValueNotifier<bool> themeNotifier = ValueNotifier<bool>(false);

