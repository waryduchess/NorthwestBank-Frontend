import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/account_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NorthwestBank'),
        actions: [
          IconButton(
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_outlined),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hola, Erik',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Tarjetas de cuentas
            const AccountCard(
              tipoCuenta: 'Cuenta de Ahorro',
              numeroCuenta: '**** **** **** 4521',
              saldo: 12450.75,
              moneda: 'USD',
            ),
            const SizedBox(height: 12),
            const AccountCard(
              tipoCuenta: 'Cuenta Corriente',
              numeroCuenta: '**** **** **** 7833',
              saldo: 3200.00,
              moneda: 'USD',
            ),

            const SizedBox(height: 24),

            // Acciones rapidas
            const Text(
              'Acciones rapidas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                QuickActionButton(
                  icon: Icons.swap_horiz,
                  label: 'Transferir',
                  onTap: () => Navigator.pushNamed(context, '/transfers'),
                ),
                QuickActionButton(
                  icon: Icons.receipt_long,
                  label: 'Historial',
                  onTap: () => Navigator.pushNamed(context, '/transactions'),
                ),
                QuickActionButton(
                  icon: Icons.payment,
                  label: 'Pagos',
                  onTap: () => Navigator.pushNamed(context, '/payments'),
                ),
                QuickActionButton(
                  icon: Icons.person_outline,
                  label: 'Perfil',
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Ultimos movimientos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ultimos movimientos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/transactions'),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const TransactionTile(
              titulo: 'Transferencia enviada',
              descripcion: 'A Juan Perez',
              monto: -500.00,
              fecha: '12 Feb 2026',
              icono: Icons.arrow_upward,
            ),
            const TransactionTile(
              titulo: 'Deposito recibido',
              descripcion: 'Nomina mensual',
              monto: 3500.00,
              fecha: '10 Feb 2026',
              icono: Icons.arrow_downward,
            ),
            const TransactionTile(
              titulo: 'Pago de servicio',
              descripcion: 'Electricidad',
              monto: -85.50,
              fecha: '8 Feb 2026',
              icono: Icons.bolt,
            ),
          ],
        ),
      ),
    );
  }
}
