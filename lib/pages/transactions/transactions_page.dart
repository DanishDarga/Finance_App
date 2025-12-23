import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/transaction.dart' as app;
import '../../models/category.dart';
import '../../models/category_data.dart';
import '../../widgets/transaction_dialog.dart';
import '../../widgets/transaction_list_item.dart';
import '../../core/constants.dart';

enum SortOption { dateDescending, amountAscending, amountDescending }

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _firestoreService = FirestoreService();
  SortOption _currentSortOption = SortOption.dateDescending;
  Category? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        elevation: 0,
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (SortOption result) {
              setState(() {
                _currentSortOption = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.dateDescending,
                child: Text('Sort by Date (Newest)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.amountAscending,
                child: Text('Sort by Amount (Low to High)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.amountDescending,
                child: Text('Sort by Amount (High to Low)'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<app.Transaction>>(
        stream: _firestoreService.getTransactionsStream(
          orderBy: _currentSortOption == SortOption.dateDescending
              ? 'date'
              : 'amount',
          descending:
              _currentSortOption == SortOption.dateDescending ||
              _currentSortOption == SortOption.amountDescending,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppConstants.errorColor),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No transactions found.',
                style: TextStyle(color: AppConstants.textSecondary),
              ),
            );
          }

          final all = snapshot.data!.docs.map((doc) => doc.data()).toList();
          final transactions = _selectedCategory == null
              ? all
              : all.where((t) => t.category == _selectedCategory).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: 8,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('All'),
                          selected: _selectedCategory == null,
                          onSelected: (s) =>
                              setState(() => _selectedCategory = null),
                        ),
                      ),
                      ...CategoryData.expenseCategories.map((c) {
                        final selected = _selectedCategory == c;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(CategoryData.displayName(c)),
                            selected: selected,
                            onSelected: (on) => setState(
                              () => _selectedCategory = on ? c : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                  ),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Dismissible(
                      key: ValueKey(transaction.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: AppConstants.errorColor,
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
                ),
              ),
            ],
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
