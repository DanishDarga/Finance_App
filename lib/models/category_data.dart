import 'package:flutter/material.dart';

class CategoryData {
  static const List<String> expenseCategories = [
    'Groceries',
    'Rent',
    'Bills',
    'Transport',
    'Entertainment',
    'Shopping',
    'Other',
  ];

  static const List<String> incomeCategories = [
    'Salary',
    'Bonus',
    'Gift',
    'Other',
  ];

  static final Map<String, Color> categoryColors = {
    'Groceries': Colors.green,
    'Rent': Colors.red,
    'Transport': Colors.blue,
    'Entertainment': Colors.purple,
    'Shopping': Colors.orange,
    'Bills': Colors.cyan,
    'Salary': Colors.lightGreen,
    'Bonus': Colors.yellow,
    'Gift': Colors.pinkAccent,
    'Other': Colors.grey,
  };

  static IconData getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return Icons.shopping_cart;
      case 'rent':
        return Icons.house;
      case 'salary':
        return Icons.work;
      case 'bills':
        return Icons.receipt;
      case 'transport':
        return Icons.directions_car;
      case 'bonus':
        return Icons.card_giftcard;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.receipt_long;
    }
  }
}
