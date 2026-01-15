import 'package:flutter/material.dart';
import '../../services/split_service.dart';
import '../../models/split_bill.dart';
import '../../core/constants.dart';

class AddSplitPage extends StatefulWidget {
  const AddSplitPage({super.key});

  @override
  State<AddSplitPage> createState() => _AddSplitPageState();
}

class _AddSplitPageState extends State<AddSplitPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _personController = TextEditingController();
  final _splitService = SplitService();

  final List<String> _people = [];

  void _addPerson() {
    final name = _personController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        _people.add(name);
        _personController.clear();
      });
    }
  }

  void _removePerson(String name) {
    setState(() {
      _people.remove(name);
    });
  }

  void _saveSplit() {
    if (_formKey.currentState!.validate()) {
      if (_people.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one person to split with')),
        );
        return;
      }

      final bill = SplitBill(
        title: _titleController.text.trim(),
        totalAmount: double.parse(_amountController.text.trim()),
        paidBy: 'You', // Simplified for now
        splitWith: _people,
        date: DateTime.now(),
      );

      _splitService.addSplitBill(bill);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (v) => v!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _personController,
                      decoration: const InputDecoration(
                        labelText: 'Add Person',
                        prefixIcon: Icon(Icons.person_add),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addPerson,
                    icon: const Icon(Icons.add_circle, size: 32),
                    color: AppConstants.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: _people.map((p) => Chip(
                  label: Text(p),
                  onDeleted: () => _removePerson(p),
                  deleteIcon: const Icon(Icons.close, size: 18),
                )).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveSplit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Save Split'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
