import 'package:flutter/material.dart';
import 'constants.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primarySwatch: Colors.blue,
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.primaryColor,
        secondary: AppConstants.primaryColor,
        surface: Colors.white10,
        onSurface: AppConstants.textSecondary,
        error: AppConstants.errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppConstants.textPrimary,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white10,
        labelStyle: TextStyle(color: AppConstants.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppConstants.textPrimary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: AppConstants.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppConstants.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.grey[50],
      primarySwatch: Colors.blue,
      colorScheme: const ColorScheme.light(
        primary: AppConstants.primaryColor,
        secondary: AppConstants.primaryColor,
        surface: Colors.white,
        onSurface: Colors.black87,
        error: AppConstants.errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        labelStyle: const TextStyle(color: Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }
}
