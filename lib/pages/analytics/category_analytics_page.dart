import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../models/transaction.dart' as app;
import '../../models/category_data.dart';
import '../../models/category.dart';
import '../../models/budget.dart';
import '../../core/constants.dart';

class CategoryAnalyticsPage extends StatefulWidget {
  const CategoryAnalyticsPage({super.key});

  @override
  State<CategoryAnalyticsPage> createState() => _CategoryAnalyticsPageState();
}

class _CategoryAnalyticsPageState extends State<CategoryAnalyticsPage> {
  final _firestore = FirestoreService();
  DateTime _currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Category Analytics')),
      body: StreamBuilder<QuerySnapshot<app.Transaction>>(
        stream: _firestore.getTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions =
              snapshot.data?.docs
                  .map((d) => d.data())
                  .where(
                    (t) =>
                        t.date.year == _currentDate.year &&
                        t.date.month == _currentDate.month,
                  )
                  .toList() ??
              [];

          final Map<Category, double> totals = {};
          double totalSpent = 0.0;
          for (final t in transactions.where((x) => x.amount < 0)) {
            totals[t.category] = (totals[t.category] ?? 0) + t.amount.abs();
            totalSpent += t.amount.abs();
          }

          final entries = totals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return StreamBuilder<Budget?>(
            stream: _firestore.getBudgetForMonth(
              _currentDate.year,
              _currentDate.month,
            ),
            builder: (context, budgetSnap) {
              final budget = budgetSnap.data;

              return ListView(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                children: [
                  _buildMonthSelector(),
                  const SizedBox(height: 12),
                  _buildTopInsight(entries, totalSpent),
                  const SizedBox(height: 12),
                  _buildPieChart(entries, totalSpent),
                  const SizedBox(height: 12),
                  ..._buildProgressBars(entries, budget),
                  const SizedBox(height: 12),
                  ...entries
                      .map((e) => _buildCategoryRow(e.key, e.value, totalSpent))
                      .toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Month: ${DateFormat(AppConstants.dateFormatMonthYear).format(_currentDate)}',
          style: const TextStyle(color: AppConstants.textPrimary, fontSize: 16),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(
                () => _currentDate = DateTime(
                  _currentDate.year,
                  _currentDate.month - 1,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(
                () => _currentDate = DateTime(
                  _currentDate.year,
                  _currentDate.month + 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopInsight(
    List<MapEntry<Category, double>> entries,
    double total,
  ) {
    if (entries.isEmpty) return const SizedBox.shrink();
    final top = entries.first;
    final pct = total > 0 ? top.value / total : 0.0;
    return Card(
      color: AppConstants.cardColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              CategoryData.categoryColors[top.key] ?? AppConstants.primaryColor,
          child: Icon(
            CategoryData.getIconForCategory(top.key),
            color: Colors.white,
          ),
        ),
        title: Text(
          'Top spending: ${CategoryData.displayName(top.key)}',
          style: const TextStyle(color: AppConstants.textPrimary),
        ),
        subtitle: Text(
          '${NumberFormat.currency(symbol: AppConstants.currencySymbol).format(top.value)} • ${(pct * 100).toStringAsFixed(1)}%',
        ),
      ),
    );
  }

  Widget _buildPieChart(
    List<MapEntry<Category, double>> entries,
    double total,
  ) {
    return SizedBox(
      height: 180,
      child: entries.isEmpty
          ? Center(
              child: Text(
                'No spending data for this month',
                style: TextStyle(color: AppConstants.textSecondary),
              ),
            )
          : CustomPaint(
              painter: _PieChartPainter(entries, total),
              child: Center(
                child: Text(
                  '${NumberFormat.currency(symbol: AppConstants.currencySymbol).format(total)}',
                  style: const TextStyle(color: AppConstants.textPrimary),
                ),
              ),
            ),
    );
  }

  List<Widget> _buildProgressBars(
    List<MapEntry<Category, double>> entries,
    Budget? budget,
  ) {
    final List<Widget> rows = [];
    final catBudgets = budget?.categoryBudgets ?? {};

    for (final e in entries) {
      final allocated = catBudgets[CategoryData.categoryToString(e.key)] ?? 0.0;
      if (allocated <= 0) continue;
      final pct = (e.value / allocated).clamp(0.0, 1.0);
      rows.add(
        Card(
          color: AppConstants.cardColor,
          margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
          child: ListTile(
            title: Text(
              CategoryData.displayName(e.key),
              style: const TextStyle(color: AppConstants.textPrimary),
            ),
            subtitle: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation(AppConstants.primaryColor),
            ),
            trailing: Text('${(pct * 100).toStringAsFixed(0)}%'),
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildCategoryRow(Category c, double amount, double total) {
    final pct = total > 0 ? (amount / total) : 0.0;
    return Card(
      color: AppConstants.cardColor,
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              CategoryData.categoryColors[c] ?? AppConstants.primaryColor,
          child: Icon(CategoryData.getIconForCategory(c), color: Colors.white),
        ),
        title: Text(
          CategoryData.displayName(c),
          style: const TextStyle(color: AppConstants.textPrimary),
        ),
        subtitle: Text(
          '${NumberFormat.currency(symbol: AppConstants.currencySymbol).format(amount)} • ${(pct * 100).toStringAsFixed(1)}%',
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<MapEntry<Category, double>> entries;
  final double total;

  _PieChartPainter(this.entries, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = rect.center;
    final radius = (size.shortestSide / 2) - 8;

    double startAngle = -3.14 / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final e in entries) {
      final sweep = total > 0 ? (e.value / total) * 3.14 * 2 : 0.0;
      paint.color = CategoryData.categoryColors[e.key] ?? Colors.grey;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
