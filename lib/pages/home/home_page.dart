import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../services/pdf_parser_service.dart';
import '../../services/auth_service.dart';
import '../../core/constants.dart';
import '../../core/theme_provider.dart';
import '../../models/transaction.dart' as app;
import '../../widgets/transaction_list_item.dart';
import '../../widgets/transaction_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _pdfParserService = PdfParserService();
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _isParsing = false;

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: _buildAppBar(),
          drawer: _buildDrawer(),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final transactions = snapshot.data!.docs
                    .map((doc) => doc.data())
                    .toList();

                double totalReceived = 0.0;
                double totalSpent = 0.0;

                for (final transaction in transactions) {
                  if (transaction.amount > 0) {
                    totalReceived += transaction.amount;
                  } else {
                    totalSpent += transaction.amount;
                  }
                }

                return _buildTransactionList(
                  context,
                  transactions,
                  totalReceived,
                  totalSpent,
                );
              },
            ),
          ),
        ),
        if (_isParsing) const Positioned.fill(child: MinimalLoader()),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
                style: TextStyle(color: AppConstants.errorColor),
              ),
            ),
          ],
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          color: Theme.of(context).cardColor,
        ),
      ],
    );
  }

  Drawer _buildDrawer() {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: theme.cardColor),
              accountName: Text(
                _getUserDisplayName(),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                _user?.email ?? '',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppConstants.primaryColor,
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
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeTransactions);
            }),
            const Divider(),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: theme.colorScheme.onSurface,
                  ),
                  title: Text(
                    themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) {
                    // #region agent log
                    try {
                      final f = File(r'c:\finance_app\.cursor\debug.log');
                      f.writeAsStringSync(
                        '${f.existsSync() ? f.readAsStringSync() : ""}\n{"id":"log_${DateTime.now().millisecondsSinceEpoch}","timestamp":${DateTime.now().millisecondsSinceEpoch},"location":"home_page.dart:199","message":"Theme toggle switch changed","data":{"currentIsDarkMode":${themeProvider.isDarkMode}},"sessionId":"debug-session","runId":"run1","hypothesisId":"A"}\n',
                        mode: FileMode.append,
                      );
                    } catch (_) {}
                    // #endregion
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textColor: theme.colorScheme.onSurface.withOpacity(0.7),
              title: const Text('Sign Out'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildDrawerListTile(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon),
      iconColor: theme.colorScheme.onSurface.withOpacity(0.7),
      textColor: theme.colorScheme.onSurface.withOpacity(0.7),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No transactions yet.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 18,
            ),
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
    double totalReceived,
    double totalSpent,
  ) {
    final recentTransactions = transactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.paddingMedium),
        Text(
          '${_getGreeting()} ${_getUserDisplayName()}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingLarge),
        _buildBalanceCard(totalReceived, totalSpent),
        const SizedBox(height: AppConstants.paddingLarge),
        _buildQuickActionsRow(),
        const SizedBox(height: AppConstants.paddingLarge),
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
                  color: AppConstants.errorColor,
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

  Widget _buildBalanceCard(double totalReceived, double totalSpent) {
    final theme = Theme.of(context);
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIncomeExpenseColumn(
              'Received',
              totalReceived,
              AppConstants.incomeColor,
            ),
            _buildIncomeExpenseColumn(
              'Spent',
              totalSpent,
              AppConstants.expenseColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseColumn(
    String title,
    double amount,
    Color amountColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          NumberFormat.currency(
            symbol: AppConstants.currencySymbol,
          ).format(amount.abs()),
          style: TextStyle(
            color: amountColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Row _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  [
                        _quickAction(context, Icons.add, 'Add'),
                        _quickAction(context, Icons.trending_up, 'Invest'),
                        _quickAction(
                          context,
                          Icons.account_balance_wallet_outlined,
                          'Budget',
                        ),
                        _quickAction(context, Icons.receipt_long, 'Bills'),
                        _quickAction(context, Icons.bar_chart, 'Reports'),
                      ]
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingSmall,
                          ),
                          child: e,
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
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
              Navigator.pushNamed(context, AppConstants.routeReports);
            } else if (label == 'Bills') {
              Navigator.pushNamed(context, AppConstants.routeBills);
            } else if (label == 'Budget') {
              Navigator.pushNamed(context, AppConstants.routeBudget);
            } else if (label == 'Invest') {
              Navigator.pushNamed(context, AppConstants.routeInvestments);
            }
          },
          borderRadius: BorderRadius.circular(30),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).cardColor,
            child: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Future<void> _uploadAndParsePdf() async {
    final result = await FilePicker.platform.pickFiles(
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
            backgroundColor: AppConstants.successColor,
            content: Text('${items.length} transactions imported!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppConstants.errorColor,
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
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            'Confirm Deletion',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to delete ALL transactions?',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'This action cannot be undone.',
                  style: TextStyle(
                    color: AppConstants.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppConstants.errorColor.withAlpha(230),
                foregroundColor: AppConstants.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
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
      color: AppConstants.backgroundColor.withAlpha(102),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppConstants.textPrimary,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
