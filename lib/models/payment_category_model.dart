class PaymentCategoryModel {
  final String id;
  final String nombre;
  final String icono; // nombre del ícono (electricity, water, phone, etc.)
  final int orden;

  PaymentCategoryModel({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.orden,
  });

  factory PaymentCategoryModel.fromJson(Map<String, dynamic> json) {
    return PaymentCategoryModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      icono: json['icono'] ?? 'build',
      orden: json['orden'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'icono': icono,
    'orden': orden,
  };
}
