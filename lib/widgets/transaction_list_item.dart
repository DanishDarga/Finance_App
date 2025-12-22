import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category_data.dart';
import '../models/transaction.dart' as app;
import '../core/constants.dart';

class TransactionListItem extends StatelessWidget {
  final app.Transaction transaction;
  final VoidCallback onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountColor = transaction.amount < 0
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          child: Icon(
            CategoryData.getIconForCategory(transaction.category),
            color: theme.colorScheme.onPrimary,
          ),
        ),
        title: Text(
          transaction.title,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        subtitle: Text(
          DateFormat(AppConstants.dateFormatDisplay).format(transaction.date),
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        trailing: Text(
          NumberFormat.currency(
            symbol: AppConstants.currencySymbol,
          ).format(transaction.amount),
          style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
