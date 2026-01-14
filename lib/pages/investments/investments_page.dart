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
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('My Investments')),
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
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    'No investments added yet.',
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
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
                color: theme.cardTheme.color,
                margin: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingSmall,
                  horizontal: AppConstants.paddingSmall,
                ),
                child: ListTile(
                  title: Text(
                    investment.name,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Qty: ${investment.quantity} • Purchased: ${DateFormat(AppConstants.dateFormatDisplay).format(investment.purchaseDate)}',
                    style: TextStyle(color: textColor.withOpacity(0.7)),
                  ),
                  trailing: Text(
                    NumberFormat.currency(
                      symbol: AppConstants.currencySymbol,
                    ).format(investment.totalInvestment),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
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
    final dateController = TextEditingController();
    DateTime purchaseDate = DateTime.now();
    dateController.text = DateFormat(
      AppConstants.dateFormatDisplay,
    ).format(purchaseDate);

    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final dialogBg = theme.cardTheme.color;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: dialogBg,
              title: Text(
                'Add New Investment',
                style: TextStyle(color: textColor),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          controller: nameController,
                          style: TextStyle(
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Investment Name',
                            hintText: 'e.g., Reliance Stock',
                            hintStyle: TextStyle(
                              color: textColor.withOpacity(0.5),
                            ),
                            labelStyle: TextStyle(
                              color: textColor.withOpacity(0.7),
                            ),
                            prefixIcon: Icon(
                              Icons.business,
                              color: textColor.withOpacity(0.7),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.dividerColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'Please enter a name' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: quantityController,
                          style: TextStyle(
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            labelStyle: TextStyle(
                              color: textColor.withOpacity(0.7),
                            ),
                            prefixIcon: Icon(
                              Icons.pie_chart,
                              color: textColor.withOpacity(0.7),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.dividerColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'Please enter a quantity' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: investmentController,
                          style: TextStyle(
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Total Investment Amount',
                            labelStyle: TextStyle(
                              color: textColor.withOpacity(0.7),
                            ),
                            prefixIcon: Icon(
                              Icons.attach_money,
                              color: textColor.withOpacity(0.7),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.dividerColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'Please enter an amount' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: dateController,
                          style: TextStyle(
                            color: textColor,
                          ),
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Purchase Date',
                            labelStyle: TextStyle(
                              color: textColor.withOpacity(0.7),
                            ),
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: textColor.withOpacity(0.7),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.dividerColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: purchaseDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                purchaseDate = picked;
                                dateController.text = DateFormat(
                                  AppConstants.dateFormatDisplay,
                                ).format(purchaseDate);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: textColor.withOpacity(0.6)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Save'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final investment = Investment(
                        name: nameController.text,
                        quantity: double.parse(quantityController.text),
                        totalInvestment: double.parse(
                          investmentController.text,
                        ),
                        purchaseDate: purchaseDate,
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
