import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del movimiento'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con información de la transacción
            Container(
              color: AppTheme.primaryColor,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      transaction.icono,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transaction.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transaction.descripcion,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${transaction.monto > 0 ? '+' : ''}\$${transaction.monto.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: transaction.isIncome ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Detalles específicos según el tipo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailCard(
                    icon: Icons.calendar_today,
                    title: 'Fecha',
                    value: '${transaction.fecha.day} de ${_getMonthName(transaction.fecha.month)} de ${transaction.fecha.year}',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    icon: Icons.category,
                    title: 'Tipo de movimiento',
                    value: transaction.tipo,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    icon: Icons.attach_money,
                    title: 'Monto',
                    value: '\$${transaction.monto.abs().toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 24),
                  ..._buildSpecificDetails(context),
                  const SizedBox(height: 24),
                  _buildTransactionStatus(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSpecificDetails(BuildContext context) {
    switch (transaction.tipo) {
      case 'Transferencia':
        final cuentaContraparte = transaction.isIncome
            ? transaction.cuentaOrigen
            : transaction.cuentaDestino;
        final ultimos4 = (cuentaContraparte != null && cuentaContraparte.length >= 4)
            ? '**** ${cuentaContraparte.substring(cuentaContraparte.length - 4)}'
            : '—';
        final hora =
            '${transaction.fecha.hour.toString().padLeft(2, '0')}:${transaction.fecha.minute.toString().padLeft(2, '0')}';
        final nombreContraparte = transaction.isIncome
            ? transaction.nombreOrigen
            : transaction.nombreDestino;

        return [
          Text(
            'Información de la transferencia',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.person,
            title: transaction.isIncome ? 'Remitente' : 'Beneficiario',
            value: nombreContraparte ?? '—',
          ),
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.account_balance,
            title: transaction.isIncome ? 'Cuenta origen' : 'Cuenta destino',
            value: ultimos4,
          ),
          const SizedBox(height: 12),
          if (transaction.descripcion.isNotEmpty && !transaction.descripcion.startsWith('A ****') && !transaction.descripcion.startsWith('De ****')) ...[
            _buildDetailCard(
              icon: Icons.notes,
              title: 'Concepto',
              value: transaction.descripcion,
            ),
            const SizedBox(height: 12),
          ],
          _buildDetailCard(
            icon: Icons.schedule,
            title: 'Hora',
            value: hora,
          ),
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.confirmation_number,
            title: 'Referencia',
            value: transaction.referencia ?? '—',
          ),
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.security,
            title: 'Estado',
            value: 'Completada',
            valueColor: Colors.green,
          ),
        ];

      case 'Pago':
        return [
          Text(
            'Información del pago',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.business,
            title: 'Empresa',
            value: transaction.descripcion,
          ),
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.calendar_month,
            title: 'Próximo pago',
            value: 'En ${(30 - DateTime.now().day)} días',
          ),
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.receipt,
            title: 'Comprobante',
            value: '#PG${transaction.id}${DateTime.now().year}',
          ),
        ];

      case 'Deposito':
        return [
          Text(
            'Información del depósito',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.source,
            title: 'Procedencia',
            value: transaction.descripcion,
          ),
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.check_circle,
            title: 'Estado',
            value: 'Abonado a tu cuenta',
            valueColor: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.confirmation_number,
            title: 'Número de transacción',
            value: '#DEP${transaction.id}2026',
          ),
        ];

      case 'Retiro':
        return [
          Text(
            'Información del retiro',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.location_on,
            title: 'Ubicación',
            value: transaction.descripcion,
          ),
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.schedule,
            title: 'Hora del retiro',
            value: '${transaction.fecha.hour.toString().padLeft(2, '0')}:${transaction.fecha.minute.toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.confirmation_number,
            title: 'Número de transacción',
            value: '#RTR${transaction.id}${DateTime.now().year}',
          ),
        ];

      case 'Servicio':
        return [
          Text(
            'Información del pago de servicio',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.receipt_long_outlined,
            title: 'Servicio',
            value: transaction.descripcion,
          ),
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.schedule,
            title: 'Hora',
            value: '${transaction.fecha.hour.toString().padLeft(2, '0')}:${transaction.fecha.minute.toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.confirmation_number,
            title: 'Referencia',
            value: transaction.referencia ?? '—',
          ),
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.check_circle,
            title: 'Estado',
            value: 'Completado',
            valueColor: Colors.green,
          ),
        ];

      default:
        return [];
    }
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transacción completada',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Este movimiento fue procesado correctamente',
                  style: TextStyle(
                    color: Colors.green.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return months[month - 1];
  }
}
