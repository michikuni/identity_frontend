import 'package:flutter/material.dart';
import 'package:identity_frontend/core/themes/app_theme.dart';
import 'package:identity_frontend/presentation/features/auth/auth_screen.dart';
import 'package:identity_frontend/presentation/features/dash_board/dash_board_screen.dart';
import 'package:identity_frontend/presentation/features/kyc/welcome.dart';
import 'package:identity_frontend/presentation/features/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/auth': (_) => const AuthScreen(),
        '/kyc-welcome': (_) => const KycWelcomeScreen(),
        '/dashboard': (_) => const DashboardScreen(),
      },
    );
  }
}