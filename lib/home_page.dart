import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'auth_services.dart';
import 'firestore_service.dart';
import 'models/transaction.dart' as app;
import 'reports_page.dart';

enum TransactionType { expense, income }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final User? _user = FirebaseAuth.instance.currentUser;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  String _getUserDisplayName() {
    if (_user?.displayName != null && _user!.displayName!.isNotEmpty) {
      final firstName = _user!.displayName!.split(' ').first;
      return firstName.isEmpty
          ? 'User'
          : firstName[0].toUpperCase() + firstName.substring(1);
    }
    final emailPrefix = _user?.email?.split('@').first ?? 'User';
    return emailPrefix[0].toUpperCase() + emailPrefix.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1C1C1E),
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _getUserDisplayName(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(
                _user?.email ?? '',
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text(
                  _getUserDisplayName().substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 40.0, color: Colors.white),
                ),
              ),
              decoration: const BoxDecoration(color: Color(0xFF121212)),
            ),
            _buildDrawerListTile(
              icon: Icons.dashboard,
              title: 'Dashboard',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerListTile(
              icon: Icons.swap_horiz,
              title: 'Transactions',
              onTap: () {},
            ),
            _buildDrawerListTile(
              icon: Icons.pie_chart,
              title: 'Budgets',
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              iconColor: Colors.white70,
              textColor: Colors.white70,
              onTap: _signOut,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: StreamBuilder<QuerySnapshot<app.Transaction>>(
          stream: _firestoreService.getTransactionsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            final transactions = snapshot.data!.docs
                .map((doc) => doc.data())
                .toList();
            final totalBalance = transactions.fold<double>(
              0.0,
              (sum, item) => sum + item.amount,
            );

            return _buildTransactionList(context, transactions, totalBalance);
          },
        ),
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            if (label == 'Add') {
              _showAddOrEditTransactionDialog(context);
            } else if (label == 'Reports') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsPage()),
              );
            }
          },
          borderRadius: BorderRadius.circular(30),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF1C1C1E),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No transactions yet.',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 20),
          _quickAction(context, Icons.add, 'Add'),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<app.Transaction> transactions,
    double totalBalance,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          '${_getGreeting()} ${_getUserDisplayName()}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Card(
          color: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(symbol: '\$').format(totalBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _quickAction(context, Icons.add, 'Add'),
            _quickAction(context, Icons.send, 'Send'),
            _quickAction(context, Icons.receipt_long, 'Bills'),
            _quickAction(context, Icons.bar_chart, 'Reports'),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Recent Transactions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Dismissible(
                key: ValueKey(transaction.id),
                onDismissed: (direction) {
                  if (transaction.id != null) {
                    _firestoreService.deleteTransaction(transaction.id!);
                  }
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                child: _TransactionListItem(
                  transaction: transaction,
                  onTap: () => _showAddOrEditTransactionDialog(
                    context,
                    transaction: transaction,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddOrEditTransactionDialog(
    BuildContext context, {
    app.Transaction? transaction,
  }) {
    final isEditing = transaction != null;
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(
      text: transaction?.title ?? '',
    );
    final amountController = TextEditingController(
      text: transaction != null ? transaction.amount.abs().toString() : '',
    );
    TransactionType selectedType = (transaction?.amount ?? -1) < 0
        ? TransactionType.expense
        : TransactionType.income;

    final List<String> expenseCategories = [
      'Groceries',
      'Rent',
      'Bills',
      'Transport',
      'Entertainment',
      'Shopping',
      'Other',
    ];
    final List<String> incomeCategories = ['Salary', 'Bonus', 'Gift', 'Other'];

    String selectedCategory =
        transaction?.category ??
        (selectedType == TransactionType.expense
            ? expenseCategories.first
            : incomeCategories.first);

    // Ensure the initial category is valid for the transaction type.
    if (isEditing) {
      final currentCategory = transaction.category;
      if (selectedType == TransactionType.expense &&
          !expenseCategories.contains(currentCategory)) {
        selectedCategory = expenseCategories.first;
      } else if (selectedType == TransactionType.income &&
          !incomeCategories.contains(currentCategory)) {
        selectedCategory = incomeCategories.first;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1C1E),
              title: Text(
                isEditing ? 'Edit Transaction' : 'Add Transaction',
                style: const TextStyle(color: Colors.white),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ToggleButtons(
                      isSelected: [
                        selectedType == TransactionType.expense,
                        selectedType == TransactionType.income,
                      ],
                      onPressed: (index) {
                        setState(() {
                          selectedType = index == 0
                              ? TransactionType.expense
                              : TransactionType.income;
                          selectedCategory =
                              selectedType == TransactionType.expense
                              ? expenseCategories.first
                              : incomeCategories.first;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: Colors.white,
                      color: Colors.white70,
                      fillColor: Colors.blueAccent.withOpacity(0.5),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Expense'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Income'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a title' : null,
                    ),
                    TextFormField(
                      controller: amountController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '\$',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter an amount';
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: const Color(0xFF2C2C2E),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                      ),
                      items:
                          (selectedType == TransactionType.expense
                                  ? expenseCategories
                                  : incomeCategories)
                              .map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              })
                              .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final amount = double.parse(amountController.text);
                      final transactionData = app.Transaction(
                        title: titleController.text,
                        amount: selectedType == TransactionType.expense
                            ? -amount
                            : amount,
                        date: DateTime.now(),
                        category: selectedCategory,
                      );

                      if (isEditing) {
                        _firestoreService.updateTransaction(
                          transaction.id!,
                          transactionData,
                        );
                      } else {
                        _firestoreService.addTransaction(transactionData);
                      }

                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _signOut() async {
    Navigator.pop(context);
    await _authService.signOut();
  }

  Widget _buildDrawerListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      iconColor: Colors.white70,
      textColor: Colors.white70,
      onTap: onTap,
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final app.Transaction transaction;
  final VoidCallback onTap;

  const _TransactionListItem({required this.transaction, required this.onTap});

  IconData _getIconForCategory(String category) {
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

  @override
  Widget build(BuildContext context) {
    final color = transaction.amount < 0 ? Colors.white : Colors.greenAccent;
    final amountString = NumberFormat.currency(
      symbol: '\$',
    ).format(transaction.amount);

    return Card(
      color: const Color(0xFF101010),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF1C1C1E),
            child: Icon(
              _getIconForCategory(transaction.category),
              color: Colors.white70,
            ),
          ),
          title: Text(
            transaction.title,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            DateFormat.yMMMd().format(transaction.date),
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: Text(
            amountString,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
