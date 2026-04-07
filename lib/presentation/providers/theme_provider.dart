import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _colorKey = 'app_accent_color';
  Color _accentColor = const Color(0xFFE47C56); // Default orange

  Color get accentColor => _accentColor;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_colorKey);
    if (colorValue != null) {
      _accentColor = Color(colorValue);
      notifyListeners();
    }
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.value);
  }

  // Pre-defined material expressive colors
  static const List<Color> themeColors = [
    Color(0xFFE47C56), // Signature Orange
    Color(0xFFE45656), // Coral Red
    Color(0xFF56B5E4), // Ocean Blue
    Color(0xFF56E49A), // Mint Green
    Color(0xFFB556E4), // Amethyst Purple
    Color(0xFFE4D156), // Sunflower Yellow
  ];
}
