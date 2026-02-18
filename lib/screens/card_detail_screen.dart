import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CardDetailScreen extends StatelessWidget {
  final String tipoCuenta;
  final String numeroCuenta;
  final double saldo;
  final String moneda;
  final String imagenTarjeta;

  const CardDetailScreen({
    super.key,
    required this.tipoCuenta,
    required this.numeroCuenta,
    required this.saldo,
    required this.moneda,
    required this.imagenTarjeta,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tipoCuenta),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Imagen de la tarjeta con info superpuesta
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagenTarjeta),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.hardEdge,
                child: const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 24),

            // Detalles de la cuenta
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDetailRow('Tipo de cuenta', tipoCuenta),
                    const Divider(),
                    _buildDetailRow('Numero de cuenta', numeroCuenta),
                    const Divider(),
                    _buildDetailRow('Saldo disponible', '\$${saldo.toStringAsFixed(2)}'),
                    const Divider(),
                    _buildDetailRow('Moneda', moneda),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
