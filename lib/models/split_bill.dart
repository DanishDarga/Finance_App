import 'package:cloud_firestore/cloud_firestore.dart';

class SplitBill {
  final String? id;
  final String title;
  final double totalAmount;
  final String paidBy; // User ID or Name
  final List<String> splitWith; // List of names
  final DateTime date;

  SplitBill({
    this.id,
    required this.title,
    required this.totalAmount,
    required this.paidBy,
    required this.splitWith,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'totalAmount': totalAmount,
      'paidBy': paidBy,
      'splitWith': splitWith,
      'date': Timestamp.fromDate(date),
    };
  }

  factory SplitBill.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SplitBill(
      id: doc.id,
      title: data['title'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      paidBy: data['paidBy'] ?? '',
      splitWith: List<String>.from(data['splitWith'] ?? []),
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}
