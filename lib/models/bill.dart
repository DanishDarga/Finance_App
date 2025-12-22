import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  final String? id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;

  Bill({
    this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
  });

  factory Bill.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Bill(
      id: snapshot.id,
      name: data['name'],
      amount: data['amount'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isPaid: data['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'amount': amount,
      'dueDate': dueDate,
      'isPaid': isPaid,
    };
  }

  Bill copyWith({String? id}) {
    return Bill(
      id: id ?? this.id,
      name: name,
      amount: amount,
      dueDate: dueDate,
      isPaid: isPaid,
    );
  }
}
