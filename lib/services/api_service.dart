import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  //registro de usuarios
  //  Cambia esto por la IP de tu máquina (cambiala en el .env tu ip)
  static String get baseUrl => dotenv.env['API_URL']!;
  //en dado caso con no fucione con la ip del .env  comenta el de arriba y descomenta la de abajo
  //static String get baseUrl => dotenv.env['API_URL'] ?? 'http://localhost:3000/api';

  static Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String telefono,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'apellido_paterno': apellidoPaterno,
          'apellido_materno': apellidoMaterno,
          'telefono': telefono,
          'email': email,
          'password': password,
          // pin se omite → el backend lo guarda como null
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['mensaje'] ?? 'Error al registrar'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión. Verifica tu red.'};
    }
  }


  //login de usuarios
  static Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Guardar el token y nombre localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', data['token']);
      final usuario = data['usuario'];
      if (usuario != null && usuario['nombre'] != null) {
        await prefs.setString('user_name', usuario['nombre']);
      }
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['mensaje'] ?? 'Credenciales incorrectas'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Error de conexión. Verifica tu red.'};
  }
}
}