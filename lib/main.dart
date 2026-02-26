import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/start_screen.dart';
import 'screens/login_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/transfers_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/payments_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const NorthwestBankApp());
}

class NorthwestBankApp extends StatelessWidget {
  const NorthwestBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NorthwestBank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/start',
      routes: {
        '/start': (_) => StartScreen(),
        '/login': (_) => LoginScreen(),
        '/account': (_) => CreateAccountScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/transfers': (_) => const TransfersScreen(),
        '/transactions': (_) => const TransactionsScreen(),
        '/payments': (_) => const PaymentsScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}
