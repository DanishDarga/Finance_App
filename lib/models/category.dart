enum Category {
  groceries,
  rent,
  bills,
  transport,
  entertainment,
  shopping,
  health,
  utilities,
  dining,
  subscriptions,
  education,
  travel,
  savings,
  transfer,
  salary,
  bonus,
  gift,
  interest,
  investment,
  other,
}

extension CategoryExtension on Category {
  String get name => toString().split('.').last;
}

Category categoryFromString(String? value) {
  if (value == null) return Category.other;
  final v = value.trim().toLowerCase();
  for (final c in Category.values) {
    if (c.name.toLowerCase() == v) return c;
  }

  // Try some common synonyms
  switch (v) {
    case 'food':
    case 'groceries':
      return Category.groceries;
    case 'restaurant':
    case 'dining':
      return Category.dining;
    case 'payroll':
    case 'salary':
      return Category.salary;
    case 'rent':
      return Category.rent;
    case 'transport':
    case 'transportation':
      return Category.transport;
    case 'shopping':
      return Category.shopping;
    case 'entertainment':
      return Category.entertainment;
    case 'bills':
    case 'utilities':
      return Category.utilities;
    case 'other':
      return Category.other;
    default:
      return Category.other;
  }
}
