class FaqModel {
  final String id;
  final String pregunta;
  final String respuesta;
  final String categoria; // transacciones, seguridad, tarjetas, general, etc.
  final int orden;

  FaqModel({
    required this.id,
    required this.pregunta,
    required this.respuesta,
    required this.categoria,
    required this.orden,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] ?? '',
      pregunta: json['pregunta'] ?? '',
      respuesta: json['respuesta'] ?? '',
      categoria: json['categoria'] ?? 'general',
      orden: json['orden'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'pregunta': pregunta,
    'respuesta': respuesta,
    'categoria': categoria,
    'orden': orden,
  };
}
