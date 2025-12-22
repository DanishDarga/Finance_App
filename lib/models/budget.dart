import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String? id;
  final double amount;
  final int year;
  final int month;

  Budget({
    this.id,
    required this.amount,
    required this.year,
    required this.month,
  });

  factory Budget.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Budget(
      id: snapshot.id,
      amount: data['amount'],
      year: data['year'],
      month: data['month'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'amount': amount, 'year': year, 'month': month};
  }
}
