import 'package:flutter/material.dart';

// Holds the user's display settings and tells the app when they change
class SettingsProvider extends ChangeNotifier {
  // Current theme choice; starts by following the device setting
  ThemeMode _themeMode = ThemeMode.system;
  // Lets other files read the theme mode without being able to change it
  ThemeMode get themeMode => _themeMode;
  void setThemeMode(ThemeMode mode) {
    // Save the new choice into the private variable
    _themeMode = mode;
    notifyListeners();
  }

  Locale _locale = const Locale('ar');
  Locale get locale => _locale;
  // Save the new language and tell the app to rebuild
  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}
