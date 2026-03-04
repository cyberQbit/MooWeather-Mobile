import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String _tempUnit = 'C'; // 'C' or 'F'

  ThemeMode get themeMode => _themeMode;
  String get tempUnit => _tempUnit;

  ThemeProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme_mode') ?? 'dark';
    if (savedTheme == 'light')
      _themeMode = ThemeMode.light;
    else if (savedTheme == 'system')
      _themeMode = ThemeMode.system;
    else
      _themeMode = ThemeMode.dark;
    _tempUnit = prefs.getString('temp_unit') ?? 'C';
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light)
      prefs.setString('theme_mode', 'light');
    else if (mode == ThemeMode.system)
      prefs.setString('theme_mode', 'system');
    else
      prefs.setString('theme_mode', 'dark');
  }

  Future<void> setTempUnit(String unit) async {
    _tempUnit = unit;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temp_unit', unit);
  }

  /// Celsius değerini seçili birime göre çevirir (display için)
  String convertTemp(dynamic celsius) {
    if (celsius == null) return '--';
    double c;
    try {
      c = celsius is num
          ? celsius.toDouble()
          : double.parse(celsius.toString());
    } catch (_) {
      return '--';
    }
    if (_tempUnit == 'F') return (c * 9 / 5 + 32).round().toString();
    return c.round().toString();
  }

  String get unitSymbol => _tempUnit == 'F' ? '°F' : '°C';
}
