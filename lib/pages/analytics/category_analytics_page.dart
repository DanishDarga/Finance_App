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
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: Text('Category Analytics', style: TextStyle(color: textColor))),
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
                  _buildMonthSelector(theme, textColor),
                  const SizedBox(height: 12),
                  _buildTopInsight(entries, totalSpent, theme, textColor),
                  const SizedBox(height: 12),
                  _buildPieChart(entries, totalSpent, textColor),
                  const SizedBox(height: 12),
                  ..._buildProgressBars(entries, budget, theme, textColor),
                  const SizedBox(height: 12),
                  ...entries
                      .map((e) => _buildCategoryRow(e.key, e.value, totalSpent, theme, textColor))
                      .toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector(ThemeData theme, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Month: ${DateFormat(AppConstants.dateFormatMonthYear).format(_currentDate)}',
          style: TextStyle(color: textColor, fontSize: 16),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: textColor),
              onPressed: () => setState(
                () => _currentDate = DateTime(
                  _currentDate.year,
                  _currentDate.month - 1,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: textColor),
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
    ThemeData theme,
    Color textColor,
  ) {
    if (entries.isEmpty) return const SizedBox.shrink();
    final top = entries.first;
    final pct = total > 0 ? top.value / total : 0.0;
    return Card(
      color: theme.cardTheme.color,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              CategoryData.categoryColors[top.key] ?? theme.primaryColor,
          child: Icon(
            CategoryData.getIconForCategory(top.key),
            color: Colors.white,
          ),
        ),
        title: Text(
          'Top spending: ${CategoryData.displayName(top.key)}',
          style: TextStyle(color: textColor),
        ),
        subtitle: Text(
          '${NumberFormat.currency(symbol: AppConstants.currencySymbol).format(top.value)} • ${(pct * 100).toStringAsFixed(1)}%',
          style: TextStyle(color: textColor.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget _buildPieChart(
    List<MapEntry<Category, double>> entries,
    double total,
    Color textColor,
  ) {
    return SizedBox(
      height: 180,
      child: entries.isEmpty
          ? Center(
              child: Text(
                'No spending data for this month',
                style: TextStyle(color: textColor.withOpacity(0.6)),
              ),
            )
          : CustomPaint(
              painter: _PieChartPainter(entries, total),
              child: Center(
                child: Text(
                  '${NumberFormat.currency(symbol: AppConstants.currencySymbol).format(total)}',
                  style: TextStyle(color: textColor),
                ),
              ),
            ),
    );
  }

  List<Widget> _buildProgressBars(
    List<MapEntry<Category, double>> entries,
    Budget? budget,
    ThemeData theme,
    Color textColor,
  ) {
    final List<Widget> rows = [];
    final catBudgets = budget?.categoryBudgets ?? {};

    for (final e in entries) {
      final allocated = catBudgets[CategoryData.categoryToString(e.key)] ?? 0.0;
      if (allocated <= 0) continue;
      final pct = (e.value / allocated).clamp(0.0, 1.0);
      rows.add(
        Card(
          color: theme.cardTheme.color,
          margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
          child: ListTile(
            title: Text(
              CategoryData.displayName(e.key),
              style: TextStyle(color: textColor),
            ),
            subtitle: LinearProgressIndicator(
              value: pct,
              backgroundColor: theme.dividerColor,
              valueColor: AlwaysStoppedAnimation(theme.primaryColor),
            ),
            trailing: Text(
              '${(pct * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildCategoryRow(Category c, double amount, double total, ThemeData theme, Color textColor) {
    final pct = total > 0 ? (amount / total) : 0.0;
    return Card(
      color: theme.cardTheme.color,
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              CategoryData.categoryColors[c] ?? theme.primaryColor,
          child: Icon(CategoryData.getIconForCategory(c), color: Colors.white),
        ),
        title: Text(
          CategoryData.displayName(c),
          style: TextStyle(color: textColor),
        ),
        subtitle: Text(
          '${NumberFormat.currency(symbol: AppConstants.currencySymbol).format(amount)} • ${(pct * 100).toStringAsFixed(1)}%',
          style: TextStyle(color: textColor.withOpacity(0.7)),
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
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 20;

    if (entries.isEmpty || total == 0) {
        paint.color = Colors.grey.withOpacity(0.2);
        canvas.drawCircle(center, radius, paint);
        return;
    }

    for (final e in entries) {
      final sweep = total > 0 ? (e.value / total) * 3.14 * 2 : 0.0;
      paint.color = CategoryData.categoryColors[e.key] ?? Colors.grey;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
