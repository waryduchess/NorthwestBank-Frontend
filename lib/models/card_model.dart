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
  final String? categoria;
  final double? creditoDisponible;
  final double? limiteCredito;
  final String? cvv;
  final String? nip;
  final int? cuentaId;
  final String? numeroTarjetaRaw;
  final String? numeroCuentaBancaria;

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
    this.categoria,
    this.creditoDisponible,
    this.limiteCredito,
    this.cvv,
    this.nip,
    this.cuentaId,
    this.numeroTarjetaRaw,
    this.numeroCuentaBancaria,
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

  // Mapeo de tipo de tarjeta a imagen
  static String imagenParaTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'orbe':
        return 'assets/images/tarjeta_uno.png';
      case 'silverstone':
        return 'assets/images/tarjeta_dos.png';
      case 'imperium':
        return 'assets/images/tarjeta_tres.png';
      case 'nexus':
      case 'vertex':
      default:
        return 'assets/images/tarjeta_NB.jpeg';
    }
  }

  // Enmascarar número de tarjeta → **** **** **** 1234
  static String _mascarar(String numero) {
    if (numero.length < 4) return numero;
    final ultimos = numero.substring(numero.length - 4);
    return '**** **** **** $ultimos';
  }

  // Factory para respuesta real del backend (GET /tarjetas)
  factory CardModel.fromBackend(Map<String, dynamic> json, {String nombreTitular = ''}) {
    final tipo = json['tipo'] as String? ?? '';
    final rawNumero = json['numero_tarjeta'] as String? ?? '';
    return CardModel(
      id: json['id'].toString(),
      tipoCuenta: tipo,
      numeroCuenta: _mascarar(rawNumero),
      saldo: double.tryParse(json['saldo'].toString()) ?? 0.0,
      moneda: 'MXN',
      imagenTarjeta: imagenParaTipo(tipo),
      activa: json['estado'] == 'activa',
      fechaVencimiento: json['fecha_expiracion'] as String?,
      nombreTitular: nombreTitular,
      nombreUsuario: nombreTitular,
      categoria: json['categoria'] as String?,
      creditoDisponible: json['credito_disponible'] != null
          ? double.tryParse(json['credito_disponible'].toString())
          : null,
      limiteCredito: json['limite_credito'] != null
          ? double.tryParse(json['limite_credito'].toString())
          : null,
      cvv: json['cvv'] as String?,
      nip: json['nip'] as String?,
      cuentaId: json['cuenta_id'] as int?,
      numeroTarjetaRaw: rawNumero,
      numeroCuentaBancaria: json['numero_cuenta'] as String?,
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
