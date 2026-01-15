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
    final isDark = theme.brightness == Brightness.dark;
    
    // Explicitly define text colors based on brightness to prevent visibility issues
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    
    final amountColor = transaction.amount < 0
        ? AppConstants.expenseColor
        : AppConstants.incomeColor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            CategoryData.getIconForCategory(transaction.category),
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          transaction.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            DateFormat(AppConstants.dateFormatDisplay).format(transaction.date),
            style: TextStyle(
              color: subTextColor,
              fontSize: 13,
            ),
          ),
        ),
        trailing: Text(
          NumberFormat.currency(
            symbol: AppConstants.currencySymbol,
          ).format(transaction.amount),
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
