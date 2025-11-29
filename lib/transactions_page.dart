import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'firestore_service.dart';
import 'models/transaction.dart' as app;
import 'widgets/transaction_dialog.dart';
import 'widgets/transaction_list_item.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('All Transactions'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<app.Transaction>>(
        stream: _firestoreService.getTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No transactions found.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final transactions = snapshot.data!.docs
              .map((doc) => doc.data())
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Dismissible(
                key: ValueKey(transaction.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  if (transaction.id != null) {
                    _firestoreService.deleteTransaction(transaction.id!);
                  }
                },
                child: TransactionListItem(
                  transaction: transaction,
                  onTap: () => _showAddOrEditTransactionDialog(
                    context,
                    transaction: transaction,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddOrEditTransactionDialog(
    BuildContext context, {
    app.Transaction? transaction,
  }) {
    showDialog(
      context: context,
      builder: (_) => TransactionDialog(transaction: transaction),
    );
  }
}
