import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  final SharedPreferences prefs;
  bool isDarkMode;

  ThemeProvider(this.prefs) : isDarkMode = prefs.getBool('isDarkMode') ?? false;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    prefs.setBool('isDarkMode', isDarkMode);
    notifyListeners();
  }
}