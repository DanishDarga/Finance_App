import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app theme (dark/light mode)
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    // #region agent log
    try { final f = File(r'c:\finance_app\.cursor\debug.log'); f.writeAsStringSync('${f.existsSync() ? f.readAsStringSync() : ""}\n{"id":"log_${DateTime.now().millisecondsSinceEpoch}","timestamp":${DateTime.now().millisecondsSinceEpoch},"location":"theme_provider.dart:12","message":"ThemeProvider constructor called","data":{"initialThemeMode":"$_themeMode"},"sessionId":"debug-session","runId":"run1","hypothesisId":"E"}\n', mode: FileMode.append); } catch (_) {}
    // #endregion
    _loadTheme();
  }

  /// Load saved theme preference
  Future<void> _loadTheme() async {
    // #region agent log
    try { final f = File(r'c:\finance_app\.cursor\debug.log'); f.writeAsStringSync('${f.existsSync() ? f.readAsStringSync() : ""}\n{"id":"log_${DateTime.now().millisecondsSinceEpoch}","timestamp":${DateTime.now().millisecondsSinceEpoch},"location":"theme_provider.dart:17","message":"_loadTheme called","data":{"currentThemeMode":"$_themeMode"},"sessionId":"debug-session","runId":"run1","hypothesisId":"E"}\n', mode: FileMode.append); } catch (_) {}
    // #endregion
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      // #region agent log
      try { final f = File(r'c:\finance_app\.cursor\debug.log'); f.writeAsStringSync('${f.existsSync() ? f.readAsStringSync() : ""}\n{"id":"log_${DateTime.now().millisecondsSinceEpoch}","timestamp":${DateTime.now().millisecondsSinceEpoch},"location":"theme_provider.dart:20","message":"Loaded saved theme","data":{"savedTheme":"$savedTheme","currentThemeMode":"$_themeMode"},"sessionId":"debug-session","runId":"run1","hypothesisId":"E"}\n', mode: FileMode.append); } catch (_) {}
      // #endregion
      if (savedTheme != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedTheme,
          orElse: () => ThemeMode.dark,
        );
        // #region agent log
        try { final f = File(r'c:\finance_app\.cursor\debug.log'); f.writeAsStringSync('${f.existsSync() ? f.readAsStringSync() : ""}\n{"id":"log_${DateTime.now().millisecondsSinceEpoch}","timestamp":${DateTime.now().millisecondsSinceEpoch},"location":"theme_provider.dart:26","message":"Theme mode set from saved preference","data":{"newThemeMode":"$_themeMode"},"sessionId":"debug-session","runId":"run1","hypothesisId":"E"}\n', mode: FileMode.append); } catch (_) {}
        // #endregion
        notifyListeners();
      }
    } catch (e) {
      // If loading fails, use default dark mode
      _themeMode = ThemeMode.dark;
      // #region agent log
      try { final f = File(r'c:\finance_app\.cursor\debug.log'); f.writeAsStringSync('${f.existsSync() ? f.readAsStringSync() : ""}\n{"id":"log_${DateTime.now().millisecondsSinceEpoch}","timestamp":${DateTime.now().millisecondsSinceEpoch},"location":"theme_provider.dart:30","message":"_loadTheme error","data":{"error":"$e","fallbackThemeMode":"$_themeMode"},"sessionId":"debug-session","runId":"run1","hypothesisId":"E"}\n', mode: FileMode.append); } catch (_) {}
      // #endregion
    }
  }

  /// Toggle between dark and light mode
  Future<void> toggleTheme() async {
    // #region agent log
    try { final f = File(r'c:\finance_app\.cursor\debug.log'); f.writeAsStringSync('${f.existsSync() ? f.readAsStringSync() : ""}\n{"id":"log_${DateTime.now().millisecondsSinceEpoch}","timestamp":${DateTime.now().millisecondsSinceEpoch},"location":"theme_provider.dart:35","message":"toggleTheme called","data":{"currentThemeMode":"$_themeMode"},"sessionId":"debug-session","runId":"run1","hypothesisId":"A"}\n', mode: FileMode.append); } catch (_) {}
    // #endregion
    final oldMode = _themeMode;
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    // #region agent log
    try { final f = File(r'c:\finance_app\.cursor\debug.log'); f.writeAsStringSync('${f.existsSync() ? f.readAsStringSync() : ""}\n{"id":"log_${DateTime.now().millisecondsSinceEpoch}","timestamp":${DateTime.now().millisecondsSinceEpoch},"location":"theme_provider.dart:39","message":"Theme mode changed","data":{"oldMode":"$oldMode","newMode":"$_themeMode"},"sessionId":"debug-session","runId":"run1","hypothesisId":"B"}\n', mode: FileMode.append); } catch (_) {}
    // #endregion
    notifyListeners();
    // #region agent log
    try { final f = File(r'c:\finance_app\.cursor\debug.log'); f.writeAsStringSync('${f.existsSync() ? f.readAsStringSync() : ""}\n{"id":"log_${DateTime.now().millisecondsSinceEpoch}","timestamp":${DateTime.now().millisecondsSinceEpoch},"location":"theme_provider.dart:40","message":"notifyListeners called","data":{"themeMode":"$_themeMode"},"sessionId":"debug-session","runId":"run1","hypothesisId":"B"}\n', mode: FileMode.append); } catch (_) {}
    // #endregion

    // Save preference
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, _themeMode.toString());
    } catch (e) {
      // If saving fails, continue anyway
    }
  }

  /// Set theme mode explicitly
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    // Save preference
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, _themeMode.toString());
    } catch (e) {
      // If saving fails, continue anyway
    }
  }
}

