import 'bank_model.dart';

class BeneficiaryModel {
  final String id;
  final String nombre;
  final String numeroCuenta;
  final BankModel banco;
  final String tipoTransferencia; // inter-banco, intra-banco

  BeneficiaryModel({
    required this.id,
    required this.nombre,
    required this.numeroCuenta,
    required this.banco,
    required this.tipoTransferencia,
  });

  factory BeneficiaryModel.fromJson(Map<String, dynamic> json) {
    return BeneficiaryModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      numeroCuenta: json['numeroCuenta'] ?? json['numero_cuenta'] ?? '',
      banco: BankModel.fromJson(json['banco'] ?? {}),
      tipoTransferencia: json['tipoTransferencia'] ?? json['tipo_transferencia'] ?? 'inter-banco',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'numeroCuenta': numeroCuenta,
    'banco': banco.toJson(),
    'tipoTransferencia': tipoTransferencia,
  };
}
