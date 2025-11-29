import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Pages
import 'login_page.dart';
import 'registration_page.dart';
import 'auth_gate.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FinanclyApp());
}

class FinanclyApp extends StatelessWidget {
  const FinanclyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Financly',
      theme: AppTheme.darkTheme,

      // 👇 THIS IS WHAT WAS MISSING
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/auth_gate': (context) => const AuthGate(),
        '/home': (context) => const HomePage(),
      },

      home: const SplashScreen(),
    );
  }
}
