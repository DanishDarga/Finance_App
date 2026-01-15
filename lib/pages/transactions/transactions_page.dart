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

enum FilterType { all, income, expense }

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _firestoreService = FirestoreService();
  SortOption _currentSortOption = SortOption.dateDescending;
  FilterType _filterType = FilterType.all;
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
          
          // 1. Filter by Type (Income/Expense/All)
          final typeFiltered = _filterType == FilterType.all
              ? all
              : _filterType == FilterType.income
                  ? all.where((t) => t.amount > 0).toList()
                  : all.where((t) => t.amount < 0).toList();

          // 2. Filter by Category
          final transactions = _selectedCategory == null
              ? typeFiltered
              : typeFiltered.where((t) => t.category == _selectedCategory).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: SegmentedButton<FilterType>(
                  segments: const [
                    ButtonSegment(
                      value: FilterType.all,
                      label: Text('All'),
                    ),
                    ButtonSegment(
                      value: FilterType.income,
                      label: Text('Income'),
                    ),
                    ButtonSegment(
                      value: FilterType.expense,
                      label: Text('Expense'),
                    ),
                  ],
                  selected: {_filterType},
                  onSelectionChanged: (Set<FilterType> newSelection) {
                    setState(() {
                      _filterType = newSelection.first;
                    });
                  },
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Theme.of(context).colorScheme.primary.withOpacity(0.1);
                        }
                         return Theme.of(context).cardColor;
                      },
                    ),
                    foregroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                         if (states.contains(MaterialState.selected)) {
                          return Theme.of(context).colorScheme.primary;
                        }
                        return Theme.of(context).colorScheme.onSurface;
                      },
                    ),
                    side: MaterialStateProperty.all(
                      BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: 8, // Reduced since we have padding above now
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
