import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AccountCard extends StatelessWidget {
  final String tipoCuenta;
  final String numeroCuenta;
  final double saldo;
  final String moneda;

  const AccountCard({
    super.key,
    required this.tipoCuenta,
    required this.numeroCuenta,
    required this.saldo,
    required this.moneda,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tipoCuenta,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            numeroCuenta,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '\$${ saldo.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            moneda,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
