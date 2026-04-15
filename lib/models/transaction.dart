import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final String titulo;
  final String descripcion;
  final double monto;
  final DateTime fecha;
  final String tipo;
  final IconData icono;
  final String? referencia;
  final String? cuentaOrigen;
  final String? cuentaDestino;
  final String? nombreOrigen;
  final String? nombreDestino;

  Transaction({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.tipo,
    required this.icono,
    this.referencia,
    this.cuentaOrigen,
    this.cuentaDestino,
    this.nombreOrigen,
    this.nombreDestino,
  });

  bool get isIncome => monto > 0;
  bool get isExpense => monto < 0;

  String get montoFormato => (monto > 0 ? '+' : '') + monto.toStringAsFixed(2);

  factory Transaction.fromBackend(Map<String, dynamic> json) {
    final tipo = json['tipo'] as String? ?? '';
    final esIngreso = json['es_ingreso'] == true || json['es_ingreso'] == 1;
    final montoRaw = double.tryParse(json['monto'].toString()) ?? 0.0;
    final monto = esIngreso ? montoRaw.abs() : -montoRaw.abs();
    final cuentaOrigen = json['cuenta_origen'] as String?;
    final cuentaDestino = json['cuenta_destino'] as String?;

    String descripcion = json['descripcion'] as String? ?? '';
    if (descripcion.isEmpty) {
      if (tipo == 'transferencia') {
        if (esIngreso && cuentaOrigen != null && cuentaOrigen.length >= 4) {
          descripcion = 'De **** ${cuentaOrigen.substring(cuentaOrigen.length - 4)}';
        } else if (!esIngreso && cuentaDestino != null && cuentaDestino.length >= 4) {
          descripcion = 'A **** ${cuentaDestino.substring(cuentaDestino.length - 4)}';
        }
      } else {
        descripcion = _descripcionDefault(tipo);
      }
    }

    return Transaction(
      id: json['id'].toString(),
      titulo: _titulo(tipo, esIngreso),
      descripcion: descripcion,
      monto: monto,
      fecha: DateTime.parse(json['created_at'].toString()),
      tipo: _tipoLabel(tipo),
      icono: _icono(tipo, esIngreso),
      referencia: json['referencia'] as String?,
      cuentaOrigen: cuentaOrigen,
      cuentaDestino: cuentaDestino,
      nombreOrigen: json['nombre_origen'] as String?,
      nombreDestino: json['nombre_destino'] as String?,
    );
  }

  static String _titulo(String tipo, bool esIngreso) {
    switch (tipo) {
      case 'transferencia': return esIngreso ? 'Transferencia recibida' : 'Transferencia enviada';
      case 'deposito':      return 'Depósito recibido';
      case 'retiro':        return 'Retiro';
      case 'compra':        return 'Compra';
      default:              return 'Movimiento';
    }
  }

  static String _descripcionDefault(String tipo) {
    switch (tipo) {
      case 'deposito': return 'Depósito externo';
      case 'retiro':   return 'Retiro de efectivo';
      case 'compra':   return 'Compra con tarjeta';
      default:         return '';
    }
  }

  static String _tipoLabel(String tipo) {
    switch (tipo) {
      case 'transferencia': return 'Transferencia';
      case 'deposito':      return 'Deposito';
      case 'retiro':        return 'Retiro';
      case 'compra':        return 'Compra';
      default:              return 'Otro';
    }
  }

  static IconData _icono(String tipo, bool esIngreso) {
    switch (tipo) {
      case 'transferencia': return esIngreso ? Icons.arrow_downward : Icons.arrow_upward;
      case 'deposito':      return Icons.arrow_downward;
      case 'retiro':        return Icons.atm;
      case 'compra':        return Icons.shopping_cart_outlined;
      default:              return Icons.swap_horiz;
    }
  }
}
