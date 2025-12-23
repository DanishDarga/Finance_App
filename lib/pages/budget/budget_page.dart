import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../models/budget.dart';
import '../../models/transaction.dart' as app;
import '../../models/category.dart';
import '../../models/category_data.dart';
import '../../core/constants.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _firestoreService = FirestoreService();
  final DateTime _currentDate = DateTime.now();
  Category? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Budget for ${DateFormat(AppConstants.dateFormatMonthYear).format(_currentDate)}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(
              context,
              AppConstants.routeCategoryAnalytics,
            ),
          ),
        ],
      ),
      body: StreamBuilder<Budget?>(
        stream: _firestoreService.getBudgetForMonth(
          _currentDate.year,
          _currentDate.month,
        ),
        builder: (context, budgetSnapshot) {
          if (budgetSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final budget = budgetSnapshot.data;

          if (budget == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No budget set for this month.',
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => _showSetBudgetDialog(context, null),
                    child: const Text('Set Budget'),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<QuerySnapshot<app.Transaction>>(
            stream: _firestoreService.getTransactionsStream(),
            builder: (context, transactionSnapshot) {
              if (transactionSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Filter this month's expenses (amount < 0)
              final allTransactions =
                  transactionSnapshot.data?.docs
                      .map((doc) => doc.data())
                      .where(
                        (t) =>
                            t.date.year == _currentDate.year &&
                            t.date.month == _currentDate.month,
                      )
                      .toList() ??
                  [];

              final transactions = _selectedCategory == null
                  ? allTransactions.where((t) => t.amount < 0).toList()
                  : allTransactions
                        .where(
                          (t) =>
                              t.amount < 0 && t.category == _selectedCategory,
                        )
                        .toList();

              // Total spent
              final double totalSpent = transactions.fold(
                0.0,
                (sum, t) => sum + t.amount.abs(),
              );

              final remaining = budget.amount - totalSpent;
              final progress = (totalSpent / budget.amount).clamp(0.0, 1.0);

              return ListView(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                children: [
                  _buildCategoryChips(budget),
                  const SizedBox(height: 12),
                  _buildBudgetCard(budget, totalSpent, remaining, progress),
                  const SizedBox(height: 12),
                  ..._buildCategoryBreakdown(budget, allTransactions),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSetBudgetDialog(context, null),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildBudgetCard(
    Budget budget,
    double spent,
    double remaining,
    double progress,
  ) {
    return Card(
      color: AppConstants.cardColor,
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Budget',
              style: TextStyle(
                color: AppConstants.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${NumberFormat.currency(symbol: AppConstants.currencySymbol).format(spent)} / ${NumberFormat.currency(symbol: AppConstants.currencySymbol).format(budget.amount)}',
              style: const TextStyle(color: AppConstants.textSecondary),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8
                    ? AppConstants.errorColor
                    : AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              '${NumberFormat.currency(symbol: AppConstants.currencySymbol).format(remaining.abs())} ${remaining >= 0 ? 'left' : 'overspent'}',
              style: TextStyle(
                color: remaining >= 0
                    ? AppConstants.successColor
                    : AppConstants.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(Budget budget) {
    final categories = CategoryData.expenseCategories;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((c) {
          final selected = _selectedCategory == c;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              label: Text(CategoryData.displayName(c)),
              onSelected: (on) {
                setState(() {
                  _selectedCategory = on ? c : null;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildCategoryBreakdown(
    Budget budget,
    List<app.Transaction> allTransactions,
  ) {
    final Map<Category, double> spentPerCategory = {};
    for (final tx in allTransactions.where((t) => t.amount < 0)) {
      spentPerCategory[tx.category] =
          (spentPerCategory[tx.category] ?? 0) + tx.amount.abs();
    }

    final catBudgets = budget.categoryBudgets ?? {};

    final items = CategoryData.expenseCategories.map((c) {
      final spent = spentPerCategory[c] ?? 0.0;
      final allocated = catBudgets[CategoryData.categoryToString(c)] ?? 0.0;
      final pct = allocated > 0 ? (spent / allocated).clamp(0.0, 1.0) : 0.0;

      return Card(
        color: AppConstants.cardColor,
        margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                CategoryData.categoryColors[c] ?? AppConstants.primaryColor,
            child: Icon(
              CategoryData.getIconForCategory(c),
              color: Colors.white,
            ),
          ),
          title: Text(
            CategoryData.displayName(c),
            style: const TextStyle(color: AppConstants.textPrimary),
          ),
          subtitle: allocated > 0
              ? LinearProgressIndicator(
                  value: pct,
                  backgroundColor: Colors.grey.shade800,
                  valueColor: AlwaysStoppedAnimation(AppConstants.primaryColor),
                )
              : Text(
                  'Spent: ${NumberFormat.currency(symbol: AppConstants.currencySymbol).format(spent)}',
                  style: const TextStyle(color: AppConstants.textSecondary),
                ),
          trailing: Text(
            allocated > 0 ? '${(pct * 100).toStringAsFixed(0)}%' : '',
            style: const TextStyle(color: AppConstants.textPrimary),
          ),
          onTap: () => _showSetBudgetDialog(context, budget, c),
        ),
      );
    }).toList();

    return items;
  }

  void _showSetBudgetDialog(
    BuildContext context,
    Budget? existingBudget, [
    Category? forCategory,
  ]) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(
      text: existingBudget?.amount.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        title: Text(
          forCategory == null
              ? (existingBudget == null
                    ? 'Set Monthly Budget'
                    : 'Update Budget')
              : 'Set Budget for ${CategoryData.displayName(forCategory)}',
          style: const TextStyle(color: AppConstants.textPrimary),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amountController,
            style: const TextStyle(color: AppConstants.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Total Spending Limit',
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? 'Enter an amount' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppConstants.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final value = double.parse(amountController.text);

                if (forCategory == null) {
                  final budget = Budget(
                    amount: value,
                    year: _currentDate.year,
                    month: _currentDate.month,
                  );
                  _firestoreService.setBudget(budget);
                } else {
                  // Update only categoryBudgets
                  final existing = existingBudget;
                  final Map<String, double> catMap = Map.from(
                    existing?.categoryBudgets ?? {},
                  );
                  catMap[CategoryData.categoryToString(forCategory)] = value;

                  final budget = Budget(
                    id: existing?.id,
                    amount: existing?.amount ?? 0.0,
                    year: _currentDate.year,
                    month: _currentDate.month,
                    categoryBudgets: catMap,
                  );
                  _firestoreService.setBudget(budget);
                }

                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
