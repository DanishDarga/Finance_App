import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/transaction.dart' as app;
import '../models/category.dart';
import '../models/category_data.dart';
import '../core/constants.dart';

enum TransactionType { expense, income }

class TransactionDialog extends StatefulWidget {
  final app.Transaction? transaction;

  const TransactionDialog({super.key, this.transaction});

  @override
  State<TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late TransactionType _selectedType;
  late Category _selectedCategory;
  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    final initialTransaction = widget.transaction;
    _titleController = TextEditingController(
      text: initialTransaction?.title ?? '',
    );
    _amountController = TextEditingController(
      text: initialTransaction != null
          ? initialTransaction.amount.abs().toString()
          : '',
    );

    _selectedType = (initialTransaction?.amount ?? -1) < 0
        ? TransactionType.expense
        : TransactionType.income;

    final categories = _selectedType == TransactionType.expense
        ? CategoryData.expenseCategories
        : CategoryData.incomeCategories;

    _selectedCategory = initialTransaction?.category ?? categories.first;

    // Ensure the initial category is valid for the transaction type.
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final transactionData = app.Transaction(
        id: widget.transaction?.id,
        title: _titleController.text,
        amount: _selectedType == TransactionType.expense ? -amount : amount,
        date: DateTime.now(),
        category: _selectedCategory,
      );

      final firestoreService = FirestoreService();
      if (_isEditing) {
        firestoreService.updateTransaction(
          widget.transaction!.id!,
          transactionData,
        );
      } else {
        firestoreService.addTransaction(transactionData);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Explicit colors based on theme if needed, or rely on colorScheme
    final textColor = theme.colorScheme.onSurface;
    final subTextColor = theme.colorScheme.onSurface.withOpacity(0.7);
    final dialogBg = theme.cardTheme.color;

    final currentCategories = _selectedType == TransactionType.expense
        ? CategoryData.expenseCategories
        : CategoryData.incomeCategories;

    return AlertDialog(
      backgroundColor: dialogBg,
      title: Text(
        _isEditing ? 'Edit Transaction' : 'Add Transaction',
        style: TextStyle(color: textColor),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ToggleButtons(
                isSelected: [
                  _selectedType == TransactionType.expense,
                  _selectedType == TransactionType.income,
                ],
                onPressed: (index) {
                  setState(() {
                    _selectedType = index == 0
                        ? TransactionType.expense
                        : TransactionType.income;
                    _selectedCategory = _selectedType == TransactionType.expense
                        ? CategoryData.expenseCategories.first
                        : CategoryData.incomeCategories.first;
                  });
                },
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
                selectedColor: theme.colorScheme.onPrimary,
                fillColor: theme.colorScheme.primary,
                color: subTextColor,
                // We need constraints for visibility
                borderColor: theme.dividerColor,
                selectedBorderColor: theme.colorScheme.primary,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Expense'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Income'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: subTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: AppConstants.currencySymbol,
                  labelStyle: TextStyle(color: subTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter an amount';
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Category>(
                initialValue: _selectedCategory,
                dropdownColor: dialogBg,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: subTextColor),
                  enabledBorder: OutlineInputBorder(
                     borderSide: BorderSide(color: theme.dividerColor),
                     borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                ),
                items: currentCategories.map((Category category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(
                      CategoryData.displayName(category),
                      style: TextStyle(color: textColor),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: subTextColor),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onPressed: _submit,
          child: Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
