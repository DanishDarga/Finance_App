import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Financly';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Colors.blueAccent;
  static const Color backgroundColor = Colors.black;
  static const Color cardColor = Color(0xFF1C1C1E);
  static const Color surfaceColor = Color(0xFF121212);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color incomeColor = Colors.green;
  static const Color expenseColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 16.0;
  static const double borderRadiusSmall = 8.0;

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

