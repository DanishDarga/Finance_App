import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Financly';
  static const String appVersion = '1.0.0';

  // Colors
  // Colors
  static const Color primaryColor = Color(0xFF6C63FF); // Premium Violet
  static const Color secondaryColor = Color(0xFF03DAC6); // Teal Accent
  static const Color accentColor = Color(0xFFFF6584); // Soft Red for contrast

  // Backgrounds
  static const Color backgroundColorDark = Color(0xFF0A0A12); // Deep rich black/violet
  static const Color cardColorDark = Color(0xFF161622); // Slightly violet-tinted dark grey
  static const Color backgroundColorLight = Color(0xFFF5F7FA);
  static const Color cardColorLight = Colors.white;

  // Legacy/Fallback aliases for existing code
  static const Color cardColor = cardColorDark;
  static const Color backgroundColor = backgroundColorDark;

  // Gradients
  static const Color gradientStart = Color(0xFF6C63FF);
  static const Color gradientEnd = Color(0xFF4834D4);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color incomeColor = Color(0xFF00C853);
  static const Color expenseColor = Color(0xFFFF3D00);
  static const Color successColor = Color(0xFF00C853);
  static const Color errorColor = Color(0xFFD32F2F);

  // Spacing
  static const double paddingSmall = 12.0;
  static const double paddingMedium = 20.0;
  static const double paddingLarge = 32.0;
  static const double borderRadius = 24.0;
  static const double borderRadiusSmall = 12.0;

  // Routes
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeAuthGate = '/auth_gate';
  static const String routeHome = '/home';
  static const String routeTransactions = '/transactions';
  static const String routeBudget = '/budget';
  static const String routeBills = '/bills';
  static const String routeInvestments = '/investments';
  static const String routeReports = '/reports';
  static const String routeCategoryAnalytics = '/analytics/categories';

  // Currency
  static const String currencySymbol = '₹';

  // Date Formats
  static const String dateFormatDisplay = 'yMMMd';
  static const String dateFormatMonthYear = 'yMMMM';
  static const String dateFormatMonth = 'MMM';
  static const String dateFormatBankStatement = 'dd-MM-yyyy';

  // Notification
  static const int billReminderDaysBefore = 2;
  static const int billReminderHour = 10;
  static const String billNotificationChannelId = 'bill_reminders';
  static const String billNotificationChannelName = 'Bill Reminders';
}
