import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/split_service.dart';
import '../../models/split_bill.dart';
import '../../core/constants.dart';

class SplitDashboard extends StatelessWidget {
  const SplitDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final splitService = SplitService();

    return Scaffold(
      appBar: AppBar(title: const Text('Split Bills')),
      body: StreamBuilder<QuerySnapshot<SplitBill>>(
        stream: splitService.getSplitBillsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading data'));
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.group_off, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   Text(
                    'No shared expenses yet',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                   ),
                ],
              ),
            );
          }

          final bills = docs.map((d) => d.data()).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              final splitCount = bill.splitWith.length + 1; // +1 for user
              final perPerson = bill.totalAmount / splitCount;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.receipt_long, color: AppConstants.primaryColor),
                  ),
                  title: Text(bill.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Paid by ${bill.paidBy} • Split with ${bill.splitWith.join(", ")}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${AppConstants.currencySymbol}${bill.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${AppConstants.currencySymbol}${perPerson.toStringAsFixed(0)} / person',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppConstants.routeAddSplit),
        child: const Icon(Icons.add),
      ),
    );
  }
}
