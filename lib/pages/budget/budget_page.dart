import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../models/budget.dart';
import '../../models/transaction.dart' as app;
import '../../core/constants.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _firestoreService = FirestoreService();
  final DateTime _currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Budget for ${DateFormat(AppConstants.dateFormatMonthYear).format(_currentDate)}',
        ),
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
              final transactions =
                  transactionSnapshot.data?.docs
                      .map((doc) => doc.data())
                      .where(
                        (t) =>
                            t.date.year == _currentDate.year &&
                            t.date.month == _currentDate.month &&
                            t.amount < 0, // only expenses
                      )
                      .toList() ??
                  [];

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
                  _buildBudgetCard(budget, totalSpent, remaining, progress),
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
                progress > 0.8 ? AppConstants.errorColor : AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              '${NumberFormat.currency(symbol: AppConstants.currencySymbol).format(remaining.abs())} ${remaining >= 0 ? 'left' : 'overspent'}',
              style: TextStyle(
                color: remaining >= 0 ? AppConstants.successColor : AppConstants.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context, Budget? existingBudget) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(
      text: existingBudget?.amount.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        title: Text(
          existingBudget == null ? 'Set Monthly Budget' : 'Update Budget',
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final budget = Budget(
                  amount: double.parse(amountController.text),
                  year: _currentDate.year,
                  month: _currentDate.month,
                );

                _firestoreService.setBudget(budget);
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

