import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final User? _user = FirebaseAuth.instance.currentUser;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    }
    if (hour < 17) {
      return 'Good Afternoon,';
    }
    return 'Good Evening,';
  }

  String _getUserDisplayName() {
    // Use display name if available, otherwise fallback to a part of the email
    if (_user?.displayName != null && _user!.displayName!.isNotEmpty) {
      return _user!.displayName!;
    }
    return _user?.email?.split('@').first ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_getGreeting()),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // TODO: Navigate to notifications screen
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1C1C1E),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blueAccent),
              child: Text(
                'Financly Menu',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              iconColor: Colors.white70,
              textColor: Colors.white70,
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                await _authService.signOut();
                // The AuthGate will handle navigation
              },
            ),
            // TODO: Add other navigation items like Budget, Goals, etc.
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getUserDisplayName(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Balance Card
            Card(
              color: const Color(0xFF1C1C1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '\$12,345',
                      style: TextStyle(
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

            // Quick Actions
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
            // Recent Transactions (dummy)
            Text(
              'Recent Transactions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  _TransactionListItem(
                    icon: Icons.shopping_cart,
                    title: 'Groceries',
                    subtitle: 'Walmart',
                    amount: -120.50,
                  ),
                  _TransactionListItem(
                    icon: Icons.receipt,
                    title: 'Rent',
                    subtitle: 'Monthly Payment',
                    amount: -800.00,
                  ),
                  _TransactionListItem(
                    icon: Icons.work,
                    title: 'Salary',
                    subtitle: 'Monthly Paycheck',
                    amount: 2500.00,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF1C1C1E),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double amount;

  const _TransactionListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final color = amount < 0 ? Colors.white : Colors.greenAccent;
    final sign = amount < 0 ? '' : '+';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF1C1C1E),
        child: Icon(icon, color: Colors.white70),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      trailing: Text(
        '$sign\$${amount.abs().toStringAsFixed(2)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
