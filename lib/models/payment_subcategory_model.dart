class PaymentSubcategoryModel {
  final String id;
  final String categoryId;
  final String nombre; // Nombre de la empresa (Compañía A, Compañía B, etc.)
  final String codigo;
  final int orden;

  PaymentSubcategoryModel({
    required this.id,
    required this.categoryId,
    required this.nombre,
    required this.codigo,
    required this.orden,
  });

  factory PaymentSubcategoryModel.fromJson(Map<String, dynamic> json) {
    return PaymentSubcategoryModel(
      id: json['id'] ?? '',
      categoryId: json['categoryId'] ?? json['category_id'] ?? '',
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'] ?? '',
      orden: json['orden'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'nombre': nombre,
    'codigo': codigo,
    'orden': orden,
  };
}
