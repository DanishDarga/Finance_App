import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/theme_provider.dart';
import 'core/routes.dart';
import 'core/constants.dart';
import 'pages/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FinanclyApp());
}

class FinanclyApp extends StatelessWidget {
  const FinanclyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          // #region agent log
          try {
            final f = File(r'c:\finance_app\.cursor\debug.log');
            f.writeAsStringSync(
              '${f.existsSync() ? f.readAsStringSync() : ""}\n{"id":"log_${DateTime.now().millisecondsSinceEpoch}","timestamp":${DateTime.now().millisecondsSinceEpoch},"location":"main.dart:25","message":"MaterialApp Consumer builder called","data":{"themeMode":"${themeProvider.themeMode}","isDarkMode":${themeProvider.isDarkMode}},"sessionId":"debug-session","runId":"run1","hypothesisId":"D"}\n',
              mode: FileMode.append,
            );
          } catch (_) {}
          // #endregion
          return MaterialApp(
            key: ValueKey(themeProvider.themeMode),
            debugShowCheckedModeBanner: false,
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: AppConstants.routeAuthGate,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
