import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'firestore_service.dart';
import 'models/transaction.dart' as app;

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  int? _touchedIndex;

  final Color incomeColor = Colors.greenAccent;
  final Color expenseColor = Colors.redAccent;

  // Pre-defined colors for categories for a consistent look
  final Map<String, Color> _categoryColors = {
    'Groceries': Colors.green,
    'Rent': Colors.red,
    'Transport': Colors.blue,
    'Entertainment': Colors.purple,
    'Shopping': Colors.orange,
    'Bills': Colors.cyan,
    'Other': Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Spending Reports'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No transactions to report.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          // --- Bar Chart Data Processing ---
          final Map<String, Map<String, double>> monthlySummary = {};
          for (final doc in snapshot.data!.docs) {
            final transaction = doc.data();
            final monthKey = DateFormat('yyyy-MM').format(transaction.date);
            if (monthlySummary[monthKey] == null) {
              monthlySummary[monthKey] = {'income': 0.0, 'expense': 0.0};
            }

            if (transaction.amount > 0) {
              monthlySummary[monthKey]!['income'] =
                  (monthlySummary[monthKey]!['income'] ?? 0) +
                  transaction.amount;
            } else {
              monthlySummary[monthKey]!['expense'] =
                  (monthlySummary[monthKey]!['expense'] ?? 0) +
                  transaction.amount.abs();
            }
          }
          final sortedMonths = monthlySummary.keys.toList()..sort();

          // Process data for the pie chart
          final expenses = snapshot.data!.docs.where(
            (doc) => doc.data().amount < 0,
          );

          if (expenses.isEmpty) {
            return const Center(
              child: Text(
                'No expenses to report.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final Map<String, double> categoryTotals = {};
          for (var doc in expenses) {
            final transaction = doc.data();
            categoryTotals.update(
              transaction.category,
              (value) => value + transaction.amount.abs(),
              ifAbsent: () => transaction.amount.abs(),
            );
          }

          final totalExpense = categoryTotals.values.fold(
            0.0,
            (sum, item) => sum + item,
          );

          final pieChartSections = categoryTotals.entries.map((entry) {
            final category = entry.key;
            final amount = entry.value;
            final percentage = (amount / totalExpense) * 100;
            final isTouched =
                categoryTotals.keys.toList().indexOf(category) == _touchedIndex;
            final fontSize = isTouched ? 16.0 : 14.0;
            final radius = isTouched ? 110.0 : 100.0;

            return PieChartSectionData(
              color: _categoryColors[category] ?? Colors.grey,
              value: amount,
              title: '${percentage.toStringAsFixed(1)}%',
              radius: radius,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
              ),
            );
          }).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Monthly Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 250,
                    child: _buildIncomeExpenseBarChart(
                      sortedMonths,
                      monthlySummary,
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'Expense Breakdown',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                                });
                              },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: pieChartSections,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: categoryTotals.keys.map((category) {
                      return _buildLegendItem(
                        color: _categoryColors[category] ?? Colors.grey,
                        text: category,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildIncomeExpenseBarChart(
    List<String> sortedMonths,
    Map<String, Map<String, double>> monthlySummary,
  ) {
    // build grouped bar chart: income and expense side by side per month
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
              color: incomeColor,
              borderRadius: BorderRadius.circular(0),
            ),
            BarChartRodData(
              toY: expense,
              width: 8,
              color: expenseColor,
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
                  '\$${value.toInt()}',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
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
                if (idx < 0 || idx >= sortedMonths.length)
                  return const SizedBox.shrink();
                final monthKey = sortedMonths[idx];
                final date = DateTime.parse('$monthKey-01');
                final label = DateFormat('MMM').format(date);
                return Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
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
