import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';
import '../services/api_service.dart';

class CardService {
  static Future<List<CardModel>> getUserCards() async {
    final prefs = await SharedPreferences.getInstance();
    final nombreTitular = (prefs.getString('user_name') ?? '').toUpperCase();

    final result = await ApiService.getCards();
    if (!result['success']) return [];

    final List<dynamic> data = result['data'];
    return data
        .map((json) => CardModel.fromBackend(json, nombreTitular: nombreTitular))
        .toList();
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
