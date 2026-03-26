class NotificationModel {
  final String id;
  final String titulo;
  final String mensaje;
  final DateTime fecha;
  final bool leida;
  final String tipo; // success, warning, error, info
  final String? icono;

  NotificationModel({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    required this.leida,
    required this.tipo,
    this.icono,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'].toString())
          : DateTime.now(),
      leida: json['leida'] ?? false,
      tipo: json['tipo'] ?? 'info',
      icono: json['icono'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'mensaje': mensaje,
    'fecha': fecha.toIso8601String(),
    'leida': leida,
    'tipo': tipo,
    'icono': icono,
  };

  // Copiar con cambios
  NotificationModel copyWith({
    String? id,
    String? titulo,
    String? mensaje,
    DateTime? fecha,
    bool? leida,
    String? tipo,
    String? icono,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      fecha: fecha ?? this.fecha,
      leida: leida ?? this.leida,
      tipo: tipo ?? this.tipo,
      icono: icono ?? this.icono,
    );
  }
}
