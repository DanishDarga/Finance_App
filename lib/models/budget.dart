import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String? id;

  /// Total fallback amount (keeps compatibility)
  final double amount;
  final int year;
  final int month;

  /// Optional per-category budgets: key is category string, value is amount
  final Map<String, double>? categoryBudgets;

  Budget({
    this.id,
    required this.amount,
    required this.year,
    required this.month,
    this.categoryBudgets,
  });

  factory Budget.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    final Map<String, double>? catMap = data['categoryBudgets'] != null
        ? Map<String, dynamic>.from(
            data['categoryBudgets'],
          ).map((k, v) => MapEntry(k, (v as num).toDouble()))
        : null;

    return Budget(
      id: snapshot.id,
      amount: (data['amount'] as num).toDouble(),
      year: data['year'] as int,
      month: data['month'] as int,
      categoryBudgets: catMap,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'year': year,
      'month': month,
      if (categoryBudgets != null) 'categoryBudgets': categoryBudgets,
    };
  }
}
