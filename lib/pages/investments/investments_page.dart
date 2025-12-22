import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../models/investment.dart';
import '../../core/constants.dart';

class InvestmentsPage extends StatefulWidget {
  const InvestmentsPage({super.key});

  @override
  State<InvestmentsPage> createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends State<InvestmentsPage> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Investments'),
      ),
      body: StreamBuilder<QuerySnapshot<Investment>>(
        stream: _firestoreService.getInvestmentsStream(),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No investments added yet.',
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  ElevatedButton(
                    onPressed: () => _showAddInvestmentDialog(context),
                    child: const Text('Add Investment'),
                  ),
                ],
              ),
            );
          }

          final investments = snapshot.data!.docs
              .map((doc) => doc.data())
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            itemCount: investments.length,
            itemBuilder: (context, index) {
              final investment = investments[index];
              return Card(
                color: AppConstants.cardColor,
                margin: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingSmall,
                  horizontal: AppConstants.paddingSmall,
                ),
                child: ListTile(
                  title: Text(
                    investment.name,
                    style: const TextStyle(
                      color: AppConstants.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Qty: ${investment.quantity} • Purchased: ${DateFormat(AppConstants.dateFormatDisplay).format(investment.purchaseDate)}',
                    style: const TextStyle(color: AppConstants.textSecondary),
                  ),
                  trailing: Text(
                    NumberFormat.currency(
                      symbol: AppConstants.currencySymbol,
                    ).format(investment.totalInvestment),
                    style: const TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddInvestmentDialog(context),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showAddInvestmentDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final investmentController = TextEditingController();
    DateTime? purchaseDate = DateTime.now();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppConstants.cardColor,
              title: const Text(
                'Add New Investment',
                style: TextStyle(color: AppConstants.textPrimary),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: AppConstants.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Investment Name (e.g., Reliance Stock)',
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Please enter a name' : null,
                      ),
                      TextFormField(
                        controller: quantityController,
                        style: const TextStyle(color: AppConstants.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v!.isEmpty ? 'Please enter a quantity' : null,
                      ),
                      TextFormField(
                        controller: investmentController,
                        style: const TextStyle(color: AppConstants.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Total Investment Amount',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v!.isEmpty ? 'Please enter an amount' : null,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Purchased: ${DateFormat(AppConstants.dateFormatDisplay).format(purchaseDate!)}',
                          style: const TextStyle(color: AppConstants.textSecondary),
                        ),
                        trailing: const Icon(
                          Icons.calendar_today,
                          color: AppConstants.textSecondary,
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: purchaseDate!,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              purchaseDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppConstants.textSecondary),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final investment = Investment(
                        name: nameController.text,
                        quantity: double.parse(quantityController.text),
                        totalInvestment: double.parse(investmentController.text),
                        purchaseDate: purchaseDate!,
                      );
                      _firestoreService.addInvestment(investment);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

