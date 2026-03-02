class CardModel {
  final String id;
  final String tipoCuenta;
  final String numeroCuenta;
  final double saldo;
  final String moneda;
  final String imagenTarjeta;
  final bool activa;
  final String? nombreUsuario;
  final String? apellidoUsuario;
  final String? fechaVencimiento;
  final String? nombreTitular;

  CardModel({
    required this.id,
    required this.tipoCuenta,
    required this.numeroCuenta,
    required this.saldo,
    required this.moneda,
    required this.imagenTarjeta,
    required this.activa,
    this.nombreUsuario,
    this.apellidoUsuario,
    this.fechaVencimiento,
    this.nombreTitular,
  });

  // Constructor para tarjetas solicitables (inactivas)
  factory CardModel.solicitable({
    required String id,
    required String tipoCuenta,
    required String imagenTarjeta,
  }) {
    return CardModel(
      id: id,
      tipoCuenta: tipoCuenta,
      numeroCuenta: '****',
      saldo: 0.0,
      moneda: 'USD',
      imagenTarjeta: imagenTarjeta,
      activa: false,
    );
  }

  // Convertir desde JSON (para datos del backend)
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] ?? '',
      tipoCuenta: json['tipoCuenta'] ?? '',
      numeroCuenta: json['numeroCuenta'] ?? '',
      saldo: (json['saldo'] ?? 0.0).toDouble(),
      moneda: json['moneda'] ?? 'USD',
      imagenTarjeta: json['imagenTarjeta'] ?? '',
      activa: json['activa'] ?? false,
      nombreUsuario: json['nombreUsuario'],
      apellidoUsuario: json['apellidoUsuario'],
      fechaVencimiento: json['fechaVencimiento'],
      nombreTitular: json['nombreTitular'],
    );
  }

  // Convertir a JSON (para enviar al backend)
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipoCuenta': tipoCuenta,
        'numeroCuenta': numeroCuenta,
        'saldo': saldo,
        'moneda': moneda,
        'imagenTarjeta': imagenTarjeta,
        'activa': activa,
        'nombreUsuario': nombreUsuario,
        'apellidoUsuario': apellidoUsuario,
        'fechaVencimiento': fechaVencimiento,
        'nombreTitular': nombreTitular,
      };
}
