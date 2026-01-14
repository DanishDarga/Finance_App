import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';
import '../../models/bill.dart';
import '../../core/constants.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  final _firestoreService = FirestoreService();
  final _notificationService = NotificationService();

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Bills & Subscriptions')),
      body: StreamBuilder<QuerySnapshot<Bill>>(
        stream: _firestoreService.getBillsStream(),
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
                    'No bills added yet.',
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
                    onPressed: () => _showAddBillDialog(context),
                    child: const Text('Add Bill'),
                  ),
                ],
              ),
            );
          }

          final bills = snapshot.data!.docs.map((doc) => doc.data()).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              final isPaid = bill.isPaid;
              final textStyle = TextStyle(
                color: isPaid
                    ? textColor.withOpacity(0.5)
                    : textColor,
                decoration: isPaid
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              );

              return Card(
                color: theme.cardTheme.color,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: CheckboxListTile(
                  value: isPaid,
                  onChanged: (bool? newValue) {
                    if (bill.id != null && newValue != null) {
                      _firestoreService.updateBill(bill.id!, {
                        'isPaid': newValue,
                      });
                    }
                  },
                  activeColor: theme.colorScheme.primary,
                  checkColor: theme.colorScheme.onPrimary,
                  title: Text(bill.name, style: textStyle),
                  subtitle: Text(
                    'Due on: ${DateFormat(AppConstants.dateFormatDisplay).format(bill.dueDate)}',
                    style: textStyle.copyWith(
                      color: textStyle.color?.withOpacity(0.7),
                    ),
                  ),
                  secondary: Text(
                    NumberFormat.currency(
                      symbol: AppConstants.currencySymbol,
                    ).format(bill.amount),
                    style: textStyle.copyWith(fontSize: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBillDialog(context),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showAddBillDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? dueDate;
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
                'Add New Bill',
                style: TextStyle(color: textColor),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Bill Name (e.g., Netflix)',
                          labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
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
                            value!.isEmpty ? 'Please enter a name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: amountController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                            labelText: 'Amount',
                            labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: theme.dividerColor),
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: theme.colorScheme.primary),
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                            ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter an amount' : null,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          dueDate == null
                              ? 'Select Due Date'
                              : 'Due: ${DateFormat(AppConstants.dateFormatDisplay).format(dueDate!)}',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                        trailing: Icon(
                          Icons.calendar_today,
                          color: textColor.withOpacity(0.7),
                        ),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              dueDate = pickedDate;
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
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: textColor.withOpacity(0.6)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('Save'),
                  onPressed: () {
                    if (formKey.currentState!.validate() && dueDate != null) {
                      final bill = Bill(
                        name: nameController.text,
                        amount: double.parse(amountController.text),
                        dueDate: dueDate!,
                      );
                      _firestoreService.addBill(bill).then((docRef) {
                        // Schedule notification for the newly created bill
                        _notificationService.scheduleBillNotification(
                          bill.copyWith(id: docRef.id),
                        );
                      });
                      Navigator.of(context).pop();
                    } else if (dueDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppConstants.errorColor,
                          content: Text('Please select a due date.'),
                        ),
                      );
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
