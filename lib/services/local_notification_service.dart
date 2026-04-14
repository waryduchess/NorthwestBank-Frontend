import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'northwestbank_channel';
  static const _channelName = 'NorthwestBank';
  static const _seenIdsKey = 'seen_notification_ids';

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    // Solicitar permiso en Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> mostrarSiNuevas(List<Map<String, dynamic>> notificaciones) async {
    final prefs = await SharedPreferences.getInstance();
    final seenRaw = prefs.getString(_seenIdsKey);
    final Set<String> seenIds = seenRaw != null
        ? Set<String>.from(jsonDecode(seenRaw))
        : {};

    final nuevas = notificaciones.where((n) {
      final id = n['id'].toString();
      final leida = n['leida'] == true || n['leida'] == 1;
      return !leida && !seenIds.contains(id);
    }).toList();

    for (final notif in nuevas) {
      await _mostrar(
        id: int.tryParse(notif['id'].toString()) ?? 0,
        titulo: notif['titulo'] ?? 'NorthwestBank',
        mensaje: notif['mensaje'] ?? '',
      );
      seenIds.add(notif['id'].toString());
    }

    await prefs.setString(_seenIdsKey, jsonEncode(seenIds.toList()));
  }

  static Future<void> _mostrar({
    required int id,
    required String titulo,
    required String mensaje,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, titulo, mensaje, details);
  }
}
