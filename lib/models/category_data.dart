import 'package:flutter/material.dart';
import 'category.dart';

class CategoryData {
  static const List<Category> expenseCategories = [
    Category.groceries,
    Category.rent,
    Category.bills,
    Category.transport,
    Category.entertainment,
    Category.shopping,
    Category.dining,
    Category.health,
    Category.utilities,
    Category.subscriptions,
    Category.education,
    Category.travel,
    Category.savings,
    Category.transfer,
    Category.other,
  ];

  static const List<Category> incomeCategories = [
    Category.salary,
    Category.bonus,
    Category.gift,
    Category.interest,
    Category.investment,
    Category.other,
  ];

  static final Map<Category, Color> categoryColors = {
    Category.groceries: Colors.green,
    Category.rent: Colors.red,
    Category.transport: Colors.blue,
    Category.entertainment: Colors.purple,
    Category.shopping: Colors.orange,
    Category.bills: Colors.cyan,
    Category.salary: Colors.lightGreen,
    Category.bonus: Colors.yellow,
    Category.gift: Colors.pinkAccent,
    Category.other: Colors.grey,
    Category.dining: Colors.teal,
    Category.health: Colors.redAccent,
    Category.utilities: Colors.indigo,
    Category.subscriptions: Colors.deepOrange,
    Category.education: Colors.brown,
    Category.travel: Colors.indigoAccent,
    Category.savings: Colors.greenAccent,
    Category.transfer: Colors.grey,
    Category.interest: Colors.lime,
    Category.investment: Colors.lightBlue,
  };

  static String displayName(Category category) {
    switch (category) {
      case Category.groceries:
        return 'Groceries';
      case Category.rent:
        return 'Rent';
      case Category.bills:
        return 'Bills';
      case Category.transport:
        return 'Transport';
      case Category.entertainment:
        return 'Entertainment';
      case Category.shopping:
        return 'Shopping';
      case Category.dining:
        return 'Dining';
      case Category.health:
        return 'Health';
      case Category.utilities:
        return 'Utilities';
      case Category.subscriptions:
        return 'Subscriptions';
      case Category.education:
        return 'Education';
      case Category.travel:
        return 'Travel';
      case Category.savings:
        return 'Savings';
      case Category.transfer:
        return 'Transfer';
      case Category.salary:
        return 'Salary';
      case Category.bonus:
        return 'Bonus';
      case Category.gift:
        return 'Gift';
      case Category.interest:
        return 'Interest';
      case Category.investment:
        return 'Investment';
      case Category.other:
      default:
        return 'Other';
    }
  }

  static IconData getIconForCategory(Category category) {
    switch (category) {
      case Category.groceries:
        return Icons.shopping_cart;
      case Category.rent:
        return Icons.house;
      case Category.salary:
        return Icons.work;
      case Category.bills:
        return Icons.receipt;
      case Category.transport:
        return Icons.directions_car;
      case Category.bonus:
        return Icons.card_giftcard;
      case Category.entertainment:
        return Icons.movie;
      case Category.shopping:
        return Icons.shopping_bag;
      case Category.dining:
        return Icons.restaurant;
      case Category.health:
        return Icons.health_and_safety;
      case Category.utilities:
        return Icons.power;
      case Category.subscriptions:
        return Icons.repeat;
      case Category.education:
        return Icons.school;
      case Category.travel:
        return Icons.flight;
      case Category.savings:
        return Icons.savings;
      case Category.transfer:
        return Icons.swap_horiz;
      case Category.gift:
        return Icons.card_giftcard;
      case Category.interest:
        return Icons.trending_up;
      case Category.investment:
        return Icons.show_chart;
      case Category.other:
      default:
        return Icons.receipt_long;
    }
  }

  static Category categoryFromName(String? name) {
    return categoryFromString(name);
  }

  /// Very small keyword-based classifier used for auto-categorization.
  static Category autoCategorize(String title, double amount) {
    final t = title.toLowerCase();

    if (t.contains('groc') ||
        t.contains('super') ||
        t.contains('market') ||
        t.contains('aldi') ||
        t.contains('walmart') ||
        t.contains('wholefoods')) {
      return Category.groceries;
    }
    if (t.contains('rent') || t.contains('lease') || t.contains('apartment'))
      return Category.rent;
    if (t.contains('uber') ||
        t.contains('lyft') ||
        t.contains('taxi') ||
        t.contains('bus') ||
        t.contains('train') ||
        t.contains('fuel') ||
        t.contains('petrol')) {
      return Category.transport;
    }
    if (t.contains('starb') ||
        t.contains('cafe') ||
        t.contains('restaurant') ||
        t.contains('diner') ||
        t.contains('zomato') ||
        t.contains('swiggy'))
      return Category.dining;
    if (t.contains('netflix') ||
        t.contains('spotify') ||
        t.contains('subscription') ||
        t.contains('hulu') ||
        t.contains('primevideo'))
      return Category.subscriptions;
    if (t.contains('amazon') ||
        t.contains('flipkart') ||
        t.contains('shop') ||
        t.contains('store') ||
        t.contains('mall'))
      return Category.shopping;
    if (t.contains('health') ||
        t.contains('clinic') ||
        t.contains('pharm') ||
        t.contains('hospital') ||
        t.contains('doctor'))
      return Category.health;
    if (t.contains('flight') ||
        t.contains('airbnb') ||
        t.contains('hotel') ||
        t.contains('travel') ||
        t.contains('booking'))
      return Category.travel;
    if (t.contains('salary') ||
        t.contains('payroll') ||
        t.contains('direct deposit') ||
        t.contains('paytm') ||
        t.contains('salarycredit'))
      return Category.salary;
    if (t.contains('bonus') ||
        (t.contains('refund') && amount > 0) ||
        t.contains('cashback'))
      return Category.bonus;
    if (t.contains('interest') || t.contains('dividend'))
      return Category.interest;
    if (t.contains('investment') ||
        t.contains('stock') ||
        t.contains('broker') ||
        t.contains('mutual'))
      return Category.investment;

    // common bill / utility keywords
    if (t.contains('electric') ||
        t.contains('power') ||
        t.contains('water') ||
        t.contains('bill') ||
        t.contains('payment') ||
        t.contains('jio') ||
        t.contains('airtel') ||
        t.contains('vodafone')) {
      return Category.utilities;
    }

    // ATM / cash withdrawal
    if (t.contains('atm') ||
        t.contains('cash withdrawal') ||
        t.contains('withdrawal'))
      return Category.transfer;

    // If positive amount and not matched, consider income
    if (amount > 0) return Category.salary;

    return Category.other;
  }

  static String categoryToString(Category category) => category.name;
}
