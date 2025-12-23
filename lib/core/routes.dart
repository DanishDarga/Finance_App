import 'package:flutter/material.dart';
import '../pages/auth/auth_gate.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/registration_page.dart';
import '../pages/home/home_page.dart';
import '../pages/transactions/transactions_page.dart';
import '../pages/budget/budget_page.dart';
import '../pages/bills/bills_page.dart';
import '../pages/investments/investments_page.dart';
import '../pages/reports/reports_page.dart';
import '../pages/analytics/category_analytics_page.dart';
import 'constants.dart';

/// App routing configuration
class AppRoutes {
  AppRoutes._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeLogin:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case AppConstants.routeRegister:
        return MaterialPageRoute(
          builder: (_) => const RegistrationPage(),
          settings: settings,
        );
      case AppConstants.routeAuthGate:
        return MaterialPageRoute(
          builder: (_) => const AuthGate(),
          settings: settings,
        );
      case AppConstants.routeHome:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case AppConstants.routeTransactions:
        return MaterialPageRoute(
          builder: (_) => const TransactionsPage(),
          settings: settings,
        );
      case AppConstants.routeBudget:
        return MaterialPageRoute(
          builder: (_) => const BudgetPage(),
          settings: settings,
        );
      case AppConstants.routeBills:
        return MaterialPageRoute(
          builder: (_) => const BillsPage(),
          settings: settings,
        );
      case AppConstants.routeInvestments:
        return MaterialPageRoute(
          builder: (_) => const InvestmentsPage(),
          settings: settings,
        );
      case AppConstants.routeReports:
        return MaterialPageRoute(
          builder: (_) => const ReportsPage(),
          settings: settings,
        );
      case AppConstants.routeCategoryAnalytics:
        return MaterialPageRoute(
          builder: (_) => const CategoryAnalyticsPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
