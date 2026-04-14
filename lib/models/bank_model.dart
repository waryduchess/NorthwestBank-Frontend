class BankModel {
  final String id;
  final String nombre;
  final String codigo;
  final String? logo; 

  BankModel({
    required this.id,
    required this.nombre,
    required this.codigo,
    this.logo,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'] ?? '',
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'codigo': codigo,
    'logo': logo,
  };
}
