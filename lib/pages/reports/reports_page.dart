import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../services/firestore_service.dart';
import '../../models/transaction.dart' as app;
import '../../models/category_data.dart';
import '../../models/category.dart';
import '../analytics/category_analytics_page.dart';
import '../../core/constants.dart';
import '../../core/constants.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final _firestoreService = FirestoreService();

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurface.withOpacity(0.6);

    return Scaffold(
      appBar: AppBar(title: Text('Spending Reports', style: TextStyle(color: textColor)), elevation: 0),
      body: StreamBuilder<QuerySnapshot<app.Transaction>>(
        stream: _firestoreService.getTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No transactions to report.',
                style: TextStyle(color: secondaryTextColor),
              ),
            );
          }

          final transactions = snapshot.data!.docs
              .map((doc) => doc.data())
              .toList();

          // Category totals for current month
          final now = DateTime.now();
          final monthTransactions = transactions
              .where(
                (t) => t.date.year == now.year && t.date.month == now.month,
              )
              .toList();
          final Map<Category, double> catTotals = {};
          double monthTotal = 0.0;
          for (final t in monthTransactions.where((x) => x.amount < 0)) {
            catTotals[t.category] =
                (catTotals[t.category] ?? 0) + t.amount.abs();
            monthTotal += t.amount.abs();
          }
          final catEntries = catTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // Data Processing
          final monthlySummary = _calculateMonthlySummary(transactions);
          final sortedMonths = monthlySummary.keys.toList()..sort();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                children: [
                   Text(
                    'Monthly Summary',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  SizedBox(
                    height: 250,
                    child: _buildIncomeExpenseBarChart(
                      sortedMonths,
                      monthlySummary,
                      textColor,
                      secondaryTextColor,
                      isDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  Text(
                    'Category Breakdown (This Month)',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  SizedBox(
                    height: 220,
                    child: catEntries.isEmpty
                        ? Center(
                            child: Text(
                              'No spending this month',
                              style: TextStyle(
                                color: secondaryTextColor,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: PieChart(
                              PieChartData(
                                sections: catEntries.map((e) {
                                  final pct = monthTotal > 0
                                      ? e.value / monthTotal
                                      : 0.0;
                                  return PieChartSectionData(
                                    color:
                                        CategoryData.categoryColors[e.key] ??
                                        Colors.grey,
                                    value: e.value,
                                    title: '${(pct * 100).toStringAsFixed(0)}%',
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList(),
                                sectionsSpace: 2,
                                centerSpaceRadius: 36,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  Center(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        minimumSize: Size.zero,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppConstants.routeCategoryAnalytics,
                      ),
                      icon: Icon(
                        Icons.analytics,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        'Open Analytics',
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Map<String, Map<String, double>> _calculateMonthlySummary(
    List<app.Transaction> transactions,
  ) {
    final Map<String, Map<String, double>> summary = {};
    for (final transaction in transactions) {
      final monthKey = DateFormat('yyyy-MM').format(transaction.date);
      summary.putIfAbsent(monthKey, () => {'income': 0.0, 'expense': 0.0});

      if (transaction.amount > 0) {
        summary[monthKey]!['income'] =
            (summary[monthKey]!['income'] ?? 0) + transaction.amount;
      } else {
        summary[monthKey]!['expense'] =
            (summary[monthKey]!['expense'] ?? 0) + transaction.amount.abs();
      }
    }
    return summary;
  }

  Widget _buildIncomeExpenseBarChart(
    List<String> sortedMonths,
    Map<String, Map<String, double>> monthlySummary,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    // Build grouped bar chart: income and expense side by side per month
    double maxY = 0.0;
    final barGroups = <BarChartGroupData>[];

    for (var i = 0; i < sortedMonths.length; i++) {
      final monthKey = sortedMonths[i];
      final income = monthlySummary[monthKey]?['income'] ?? 0.0;
      final expense = monthlySummary[monthKey]?['expense'] ?? 0.0;
      maxY = math.max(maxY, math.max(income, expense));

      barGroups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: income,
              width: 8,
              color: AppConstants.incomeColor,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              toY: expense,
              width: 8,
              color: AppConstants.expenseColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    }

    final chartMaxY = maxY > 0 ? maxY * 1.2 : 10.0;

    return BarChart(
      BarChartData(
        maxY: chartMaxY,
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: isDark ? Colors.white12 : Colors.black12, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '${AppConstants.currencySymbol}${value.toInt()}',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (double value, TitleMeta meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= sortedMonths.length) {
                  return const SizedBox.shrink();
                }
                final monthKey = sortedMonths[idx];
                final date = DateTime.parse('$monthKey-01');
                final label = DateFormat(
                  AppConstants.dateFormatMonth,
                ).format(date);
                return Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: true),
      ),
    );
  }
}
