import 'dart:convert';
import 'dart:io';
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
      // Guardar el token y datos del usuario localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', data['token']);
      final usuario = data['usuario'];
      if (usuario != null) {
        if (usuario['nombre'] != null) {
          await prefs.setString('user_name', usuario['nombre']);
        }
        if (usuario['foto_url'] != null) {
          await prefs.setString('foto_url', usuario['foto_url']);
        } else {
          await prefs.remove('foto_url');
        }
      }
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['mensaje'] ?? 'Credenciales incorrectas'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Error de conexión. Verifica tu red.'};
  }
}

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/perfil'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['foto_url'] != null) {
          await prefs.setString('foto_url', data['foto_url']);
        } else {
          await prefs.remove('foto_url');
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['mensaje'] ?? 'Error al obtener perfil'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión. Verifica tu red.'};
    }
  }

  static Future<Map<String, dynamic>> uploadProfilePhoto(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/usuarios/foto'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('foto_url', data['foto_url']);
        return {'success': true, 'foto_url': data['foto_url']};
      } else {
        return {'success': false, 'message': data['mensaje'] ?? 'Error al subir la foto'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión. Verifica tu red.'};
    }
  }
}