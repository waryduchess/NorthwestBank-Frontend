class PaymentServiceModel {
  final String id;
  final String subcategoryId;
  final String nombre;
  final String codigo;
  final bool requiereReferencia; // Si requiere número de referencia/cuenta/etc

  PaymentServiceModel({
    required this.id,
    required this.subcategoryId,
    required this.nombre,
    required this.codigo,
    required this.requiereReferencia,
  });

  factory PaymentServiceModel.fromJson(Map<String, dynamic> json) {
    return PaymentServiceModel(
      id: json['id'] ?? '',
      subcategoryId: json['subcategoryId'] ?? json['subcategory_id'] ?? '',
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'] ?? '',
      requiereReferencia: json['requiereReferencia'] ?? json['requiere_referencia'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'subcategoryId': subcategoryId,
    'nombre': nombre,
    'codigo': codigo,
    'requiereReferencia': requiereReferencia,
  };
}
