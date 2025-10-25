import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String? id; // The document ID from Firestore
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  // Factory constructor to create a Transaction from a Firestore document
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'] ?? 'General',
    );
  }

  // Method to convert a Transaction object into a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
    };
  }
}
