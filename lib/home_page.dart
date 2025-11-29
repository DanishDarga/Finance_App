import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'auth_services.dart';
import 'firestore_service.dart';
import 'models/transaction.dart' as app;
import 'services/pdf_parser.dart';
import 'models/category_data.dart';
import 'reports_page.dart';
import 'transactions_page.dart';
import 'widgets/transaction_list_item.dart';
import 'widgets/transaction_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final PdfParserService _pdfParserService = PdfParserService();
  final User? _user = FirebaseAuth.instance.currentUser;

  bool _isParsing = false;

  // -------------------------------------------------
  // Helpers
  // -------------------------------------------------
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  String _getUserDisplayName() {
    if (_user?.displayName != null && _user?.displayName!.isNotEmpty == true) {
      final firstName = _user!.displayName!.split(' ').first;
      return firstName[0].toUpperCase() + firstName.substring(1);
    }

    final emailPrefix = _user?.email?.split('@').first ?? 'User';
    return emailPrefix[0].toUpperCase() + emailPrefix.substring(1);
  }

  // -------------------------------------------------
  // UI
  // -------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: _buildAppBar(),
          drawer: _buildDrawer(),
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
                  (previousValue, item) => previousValue + item.amount,
                );

                return _buildTransactionList(
                  context,
                  transactions,
                  totalBalance,
                );
              },
            ),
          ),
        ),

        if (_isParsing) const Positioned.fill(child: MinimalLoader()),
      ],
    );
  }

  // -------------------------------------------------
  // AppBar
  // -------------------------------------------------
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text('Dashboard'),
      actions: [
        IconButton(
          icon: const Icon(Icons.upload_file),
          tooltip: 'Upload Bank Statement',
          onPressed: _uploadAndParsePdf,
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'deleteAll') {
              _confirmDeleteAllTransactions();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'deleteAll',
              child: Text(
                'Delete All Transactions',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
          icon: const Icon(Icons.more_vert, color: Colors.white),
        ),
      ],
    );
  }

  // -------------------------------------------------
  // Drawer
  // -------------------------------------------------
  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1C1C1E),
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF121212)),
            accountName: Text(
              _getUserDisplayName(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              _user?.email ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                _getUserDisplayName()[0],
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
          ),

          _buildDrawerListTile(Icons.dashboard, 'Dashboard', () {
            Navigator.pop(context);
          }),

          _buildDrawerListTile(Icons.swap_horiz, 'Transactions', () {
            Navigator.pop(context); // Close drawer
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionsPage()),
            );
          }),

          ListTile(
            leading: const Icon(Icons.logout),
            iconColor: Colors.white70,
            textColor: Colors.white70,
            title: const Text('Sign Out'),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerListTile(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      iconColor: Colors.white70,
      textColor: Colors.white70,
      title: Text(title),
      onTap: onTap,
    );
  }

  // -------------------------------------------------
  // Body
  // -------------------------------------------------
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
    final recentTransactions = transactions.take(5).toList();

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

        _buildBalanceCard(totalBalance),

        const SizedBox(height: 24),

        _buildQuickActionsRow(),

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
            itemCount: recentTransactions.length,
            itemBuilder: (context, index) {
              final transaction = recentTransactions[index];

              return Dismissible(
                key: ValueKey(transaction.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  if (transaction.id != null) {
                    _firestoreService.deleteTransaction(transaction.id!);
                  }
                },
                child: TransactionListItem(
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

  // -------------------------------------------------
  // Cards / UI sections
  // -------------------------------------------------
  Widget _buildBalanceCard(double totalBalance) {
    return Card(
      color: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(symbol: '₹').format(totalBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _buildQuickActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _quickAction(context, Icons.add, 'Add'),
        _quickAction(context, Icons.send, 'Send'),
        _quickAction(context, Icons.receipt_long, 'Bills'),
        _quickAction(context, Icons.bar_chart, 'Reports'),
      ],
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
                MaterialPageRoute(builder: (_) => const ReportsPage()),
              );
            }
          },
          borderRadius: BorderRadius.circular(30),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF1C1C1E),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  // -------------------------------------------------
  // PDF parsing
  // -------------------------------------------------
  Future<void> _uploadAndParsePdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() => _isParsing = true);

    try {
      final String path = result.files.single.path!;
      final List<app.Transaction> items = await _pdfParserService
          .parseBankStatement(path);

      for (final transaction in items) {
        await _firestoreService.addTransaction(transaction);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('${items.length} transactions imported!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error parsing PDF: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isParsing = false);
    }
  }

  Future<void> _confirmDeleteAllTransactions() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title: const Text(
            'Confirm Deletion',
            style: TextStyle(color: Colors.white),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to delete ALL transactions?',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 8),
                Text(
                  'This action cannot be undone.',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.withAlpha(230),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Delete All'),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _firestoreService.deleteAllTransactions();
              },
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------
  // Misc
  // -------------------------------------------------
  void _showAddOrEditTransactionDialog(
    BuildContext context, {
    app.Transaction? transaction,
  }) {
    showDialog(
      context: context,
      builder: (_) => TransactionDialog(transaction: transaction),
    );
  }

  void _signOut() async {
    Navigator.pop(context);
    await _authService.signOut();
  }
}

class MinimalLoader extends StatelessWidget {
  const MinimalLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(102), // subtle dim background
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
      ),
    );
  }
}
