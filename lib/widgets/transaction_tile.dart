import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final double monto;
  final String fecha;
  final IconData icono;

  const TransactionTile({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    final bool esIngreso = monto > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (esIngreso ? AppTheme.accentColor : AppTheme.errorColor)
              .withValues(alpha: 0.15),
          child: Icon(
            icono,
            color: esIngreso ? AppTheme.accentColor : AppTheme.errorColor,
            size: 22,
          ),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        subtitle: Text(
          descripcion,
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${esIngreso ? '+' : ''}\$${monto.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: esIngreso ? AppTheme.accentColor : AppTheme.errorColor,
              ),
            ),
            Text(
              fecha,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
