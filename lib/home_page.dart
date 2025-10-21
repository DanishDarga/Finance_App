import 'package:flutter/material.dart';
import 'auth_services.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financly'),
        centerTitle: true,
        // The hamburger menu icon will be automatically added by Flutter
        backgroundColor: Colors.blueAccent,
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text(
                'Financly Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                await AuthService().signOut();
                // The AuthGate will handle navigation
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Balance Card
            Card(
              color: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Total Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '\$12,345',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
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
                _quickAction(Icons.add, 'Add Money'),
                _quickAction(Icons.send, 'Send'),
                _quickAction(Icons.receipt_long, 'Transactions'),
              ],
            ),

            const SizedBox(height: 24),
            // Recent Transactions (dummy)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.shopping_cart),
                    title: Text('Grocery'),
                    trailing: Text('-\$120'),
                  ),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Rent'),
                    trailing: Text('-\$800'),
                  ),
                  ListTile(
                    leading: Icon(Icons.payment),
                    title: Text('Salary'),
                    trailing: Text('+\$2500'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blueAccent,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
