import 'package:cloud_firestore/cloud_firestore.dart';

class Investment {
  final String? id;
  final String name;
  final double quantity;
  final double totalInvestment;
  final DateTime purchaseDate;

  Investment({
    this.id,
    required this.name,
    required this.quantity,
    required this.totalInvestment,
    required this.purchaseDate,
  });

  factory Investment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Investment(
      id: snapshot.id,
      name: data['name'],
      quantity: (data['quantity'] ?? 0.0).toDouble(),
      totalInvestment: (data['totalInvestment'] ?? 0.0).toDouble(),
      purchaseDate: (data['purchaseDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'quantity': quantity,
      'totalInvestment': totalInvestment,
      'purchaseDate': purchaseDate,
    };
  }
}
