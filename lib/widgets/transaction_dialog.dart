import 'package:flutter/material.dart';
import '../firestore_service.dart';
import '../models/transaction.dart' as app;
import '../models/category_data.dart';

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
  late String _selectedCategory;
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
  Widget build(BuildContext context) {
    final currentCategories = _selectedType == TransactionType.expense
        ? CategoryData.expenseCategories
        : CategoryData.incomeCategories;

    return AlertDialog(
      backgroundColor: const Color(0xFF1C1C1E),
      title: Text(
        _isEditing ? 'Edit Transaction' : 'Add Transaction',
        style: const TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
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
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              color: Colors.white70,
              fillColor: Colors.blueAccent.withOpacity(0.5),
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
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a title' : null,
            ),
            TextFormField(
              controller: _amountController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
                labelStyle: TextStyle(color: Colors.white70),
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
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: const Color(0xFF2C2C2E),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
              items: currentCategories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
