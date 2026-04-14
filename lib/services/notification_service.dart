import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationService {
  // TODO: Reemplazar esta data mock con llamada a API real cuando backend esté listo
  static const List<Map<String, dynamic>> _mockNotifications = [
    {
      'id': '1',
      'titulo': 'Transferencia realizada',
      'mensaje': 'Se transfirió \$150.00 a Juan Pérez',
      'fecha': '2024-03-23T10:30:00Z',
      'leida': false,
      'tipo': 'success',
    },
    {
      'id': '2',
      'titulo': 'Pago de servicio',
      'mensaje': 'Tu pago de electricidad ha sido procesado',
      'fecha': '2024-03-22T15:45:00Z',
      'leida': true,
      'tipo': 'info',
    },
    {
      'id': '3',
      'titulo': 'Retiro de efectivo',
      'mensaje': 'Retiraste \$200.00 en cajero automático',
      'fecha': '2024-03-21T08:12:00Z',
      'leida': true,
      'tipo': 'info',
    },
    {
      'id': '4',
      'titulo': 'Alerta de seguridad',
      'mensaje': 'Se detectó un intento de acceso no autorizado',
      'fecha': '2024-03-20T22:15:00Z',
      'leida': false,
      'tipo': 'warning',
    },
  ];

  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      // BACKEND: Descomentar estas líneas cuando API esté lista
      // final response = await http.get(
      //   Uri.parse('${ApiService.baseUrl}/notificaciones'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   final List<dynamic> notifs = data['data'] ?? [];
      //   return notifs.map((n) => NotificationModel.fromJson(n)).toList();
      // }
      // return [];

      // POR AHORA: Devolver mock data
      return _mockNotifications
          .map((n) => NotificationModel.fromJson(n))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> markAsRead(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      // BACKEND: Descomentar cuando API esté lista
      // final response = await http.put(
      //   Uri.parse('${ApiService.baseUrl}/notificaciones/$id/read'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      // return response.statusCode == 200;

      // POR AHORA: Solo retornar true
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteNotification(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      // BACKEND: Descomentar cuando API esté lista
      // final response = await http.delete(
      //   Uri.parse('${ApiService.baseUrl}/notificaciones/$id'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      // return response.statusCode == 200;

      // POR AHORA: Solo retornar true
      return true;
    } catch (e) {
      return false;
    }
  }
}
