import 'package:flutter/material.dart';
import '../../core/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay navigation until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppConstants.routeAuthGate,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          AppConstants.appName,
          style: TextStyle(
            fontFamily: 'DancingScript',
            fontSize: 72.0,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
      ),
    );
  }
}

