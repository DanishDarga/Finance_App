import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/category_data.dart';
import '../models/transaction.dart' as app;

class TransactionListItem extends StatelessWidget {
  final app.Transaction transaction;
  final VoidCallback onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = transaction.amount < 0 ? Colors.white : Colors.greenAccent;

    return Card(
      color: const Color(0xFF101010),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1C1C1E),
          child: Icon(
            CategoryData.getIconForCategory(transaction.category),
            color: Colors.white70,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          DateFormat.yMMMd().format(transaction.date),
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Text(
          NumberFormat.currency(symbol: '₹').format(transaction.amount),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
