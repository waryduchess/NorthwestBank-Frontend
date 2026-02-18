import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final String titulo;
  final String descripcion;
  final double monto;
  final DateTime fecha;
  final String tipo; // 'Transferencia', 'Deposito', 'Pago', 'Retiro'
  final IconData icono;

  Transaction({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.tipo,
    required this.icono,
  });

  // Para obtener tipo de transacción basado en el monto y titulo
  bool get isIncome => monto > 0;
  bool get isExpense => monto < 0;

  String get montoFormato => (monto > 0 ? '+' : '') + monto.toStringAsFixed(2);
}
