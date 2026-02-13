import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de movimientos')),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('Fecha'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: const Text('Tipo'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.sort, size: 18),
                    label: const Text('Monto'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de transacciones
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSectionHeader('Febrero 2026'),
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
                const TransactionTile(
                  titulo: 'Transferencia recibida',
                  descripcion: 'De Maria Lopez',
                  monto: 1200.00,
                  fecha: '5 Feb 2026',
                  icono: Icons.arrow_downward,
                ),
                _buildSectionHeader('Enero 2026'),
                const TransactionTile(
                  titulo: 'Pago de servicio',
                  descripcion: 'Agua potable',
                  monto: -45.00,
                  fecha: '28 Ene 2026',
                  icono: Icons.water_drop,
                ),
                const TransactionTile(
                  titulo: 'Retiro ATM',
                  descripcion: 'Cajero Centro',
                  monto: -200.00,
                  fecha: '25 Ene 2026',
                  icono: Icons.atm,
                ),
                const TransactionTile(
                  titulo: 'Deposito recibido',
                  descripcion: 'Nomina mensual',
                  monto: 3500.00,
                  fecha: '10 Ene 2026',
                  icono: Icons.arrow_downward,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
