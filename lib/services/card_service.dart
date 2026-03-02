import '../models/card_model.dart';

/// Servicio para gestionar datos de tarjetas
/// Este servicio actúa como interfaz entre el frontend y el backend
/// Aquí es donde se conectara con la API del backend

class CardService {
  // Simular una lista de tarjetas del usuario
  // En una aplicacion real, esto vendria del backend
  static Future<List<CardModel>> getUserCards() async {
    // TODO: Reemplazar con llamada real a la API del backend
    // return await dio.get('/api/cards')

    // Por ahora retornamos datos de ejemplo
    await Future.delayed(const Duration(seconds: 1));

    return [
      CardModel(
        id: '1',
        tipoCuenta: 'Cuenta de Ahorro',
        numeroCuenta: '**** **** **** 4521',
        saldo: 12450.75,
        moneda: 'USD',
        imagenTarjeta: 'assets/images/tarjeta_uno.png',
        activa: true,
        nombreUsuario: 'Erik',
        apellidoUsuario: '',
        fechaVencimiento: '12/25',
        nombreTitular: 'ERIK',
      ),
      CardModel(
        id: '2',
        tipoCuenta: 'Cuenta Corriente',
        numeroCuenta: '**** **** **** 7833',
        saldo: 3200.00,
        moneda: 'USD',
        imagenTarjeta: 'assets/images/tarjeta_dos.png',
        activa: true,
        nombreUsuario: 'Erik',
        apellidoUsuario: '',
        fechaVencimiento: '11/26',
        nombreTitular: 'ERIK',
      ),
      CardModel(
        id: '3',
        tipoCuenta: 'Tarjeta de Credito',
        numeroCuenta: '**** **** **** 5890',
        saldo: 8500.00,
        moneda: 'USD',
        imagenTarjeta: 'assets/images/tarjeta_tres.png',
        activa: true,
        nombreUsuario: 'Erik',
        apellidoUsuario: '',
        fechaVencimiento: '09/27',
        nombreTitular: 'ERIK',
      ),
    ];
  }

  /// Obtener detalles de una tarjeta especifica
  static Future<CardModel?> getCardDetail(String cardId) async {
    // TODO: Conectar con endpoint: GET /api/cards/{cardId}

    final cards = await getUserCards();
    return cards.where((card) => card.id == cardId).firstOrNull;
  }

  /// Solicitar una nueva tarjeta
  static Future<bool> requestNewCard(String cardType) async {
    // TODO: Conectar con endpoint: POST /api/cards/request
    // final response = await dio.post('/api/cards/request', data: {
    //   'cardType': cardType,
    //   'userId': currentUserId,
    // })

    // Simular envio al backend
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  /// Actualizar datos de una tarjeta desde el backend
  static Future<CardModel> updateCardFromBackend(CardModel card) async {
    // TODO: Conectar con endpoint: PATCH /api/cards/{cardId}
    // final response = await dio.patch('/api/cards/${card.id}')

    // Retornar la tarjeta actualizada
    return card;
  }

  /// Stream para escuchar cambios en tiempo real de las tarjetas
  /// Util para cuando el backend envia actualizaciones en tiempo real
  // static Stream<List<CardModel>> getCardsRealtime() {
  //   // TODO: Implementar WebSocket o Server-Sent Events
  //   // return socketService.getCardsStream();
  // }
}
