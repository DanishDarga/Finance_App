import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../services/firestore_service.dart';
import '../../models/transaction.dart' as app;
import '../../core/constants.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Reports'),
        elevation: 0,
      ),
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
                style: const TextStyle(color: AppConstants.errorColor),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No transactions to report.',
                style: TextStyle(color: AppConstants.textSecondary),
              ),
            );
          }

          final transactions = snapshot.data!.docs
              .map((doc) => doc.data())
              .toList();

          // Data Processing
          final monthlySummary = _calculateMonthlySummary(transactions);
          final sortedMonths = monthlySummary.keys.toList()..sort();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                children: [
                  const Text(
                    'Monthly Summary',
                    style: TextStyle(
                      color: AppConstants.textPrimary,
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
              borderRadius: BorderRadius.circular(0),
            ),
            BarChartRodData(
              toY: expense,
              width: 8,
              color: AppConstants.expenseColor,
              borderRadius: BorderRadius.circular(0),
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
            return FlLine(color: Colors.white12, strokeWidth: 1);
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
                  style: const TextStyle(
                    color: AppConstants.textSecondary,
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
                final label = DateFormat(AppConstants.dateFormatMonth).format(date);
                return Text(
                  label,
                  style: const TextStyle(
                    color: AppConstants.textPrimary,
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

