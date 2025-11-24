import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Keep splash screen for initial launch
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue, // We'll use your cursive font
      ),
      home: const SplashScreen(),
    );
  }
}