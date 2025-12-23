import 'package:cloud_firestore/cloud_firestore.dart';
import 'category.dart';
import 'category_data.dart';

class Transaction {
  final String? id; // The document ID from Firestore
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

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
    final rawCategory = data['category'] as String?;
    Category parsedCategory = CategoryData.categoryFromName(rawCategory);

    // If category is missing or 'other', try auto-categorize based on title/amount
    if ((rawCategory == null ||
            rawCategory.isEmpty ||
            parsedCategory == Category.other) &&
        data['title'] != null) {
      final amt = (data['amount'] ?? 0.0).toDouble();
      parsedCategory = CategoryData.autoCategorize(
        data['title'].toString(),
        amt,
      );
    }

    return Transaction(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      category: parsedCategory,
    );
  }

  // Method to convert a Transaction object into a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': CategoryData.categoryToString(category),
    };
  }
}
