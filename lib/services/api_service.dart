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

  static Future<Map<String, dynamic>> getAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final response = await http.get(
        Uri.parse('$baseUrl/cuentas'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': '${data['mensaje'] ?? 'Error al obtener cuentas'} (código ${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> registerCard({
    required int cuentaId,
    required int tipoTarjetaId,
    required String numeroTarjeta,
    required String cvv,
    required String fechaExpiracion,
    required String nip,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final response = await http.post(
        Uri.parse('$baseUrl/tarjetas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cuenta_id': cuentaId,
          'tipo_tarjeta_id': tipoTarjetaId,
          'numero_tarjeta': numeroTarjeta,
          'cvv': cvv,
          'fecha_expiracion': fechaExpiracion,
          'nip': nip,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['mensaje'] ?? 'Error al registrar tarjeta'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión. Verifica tu red.'};
    }
  }

  static Future<Map<String, dynamic>> transfer({
    required int cuentaOrigenId,
    required String numeroCuentaDestino,
    required double monto,
    String? descripcion,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final response = await http.post(
        Uri.parse('$baseUrl/transacciones/transferir'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cuenta_origen_id': cuentaOrigenId,
          'numero_cuenta_destino': numeroCuentaDestino,
          'monto': monto,
          if (descripcion != null && descripcion.isNotEmpty) 'descripcion': descripcion,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['mensaje'] ?? 'Error al realizar transferencia'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión. Verifica tu red.'};
    }
  }

  static Future<Map<String, dynamic>> transferByCard({
    required int cuentaOrigenId,
    required String numeroTarjetaDestino,
    required double monto,
    String? descripcion,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final response = await http.post(
        Uri.parse('$baseUrl/transacciones/transferir'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cuenta_origen_id': cuentaOrigenId,
          'numero_tarjeta_destino': numeroTarjetaDestino,
          'monto': monto,
          if (descripcion != null && descripcion.isNotEmpty) 'descripcion': descripcion,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['mensaje'] ?? 'Error al realizar transferencia'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión. Verifica tu red.'};
    }
  }

  static Future<Map<String, dynamic>> getCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final response = await http.get(
        Uri.parse('$baseUrl/tarjetas'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['mensaje'] ?? 'Error al obtener tarjetas'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión. Verifica tu red.'};
    }
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final response = await http.get(
        Uri.parse('$baseUrl/transacciones'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((t) => Map<String, dynamic>.from(t)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> updateBiometria({
    required bool activa,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final response = await http.patch(
        Uri.parse('$baseUrl/usuarios/biometria'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'activa': activa}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': data['mensaje'] ?? 'Error al actualizar biometría'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión. Verifica tu red.'};
    }
  }

  static Future<Map<String, dynamic>> updatePassword({
    required String passwordActual,
    required String passwordNueva,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final response = await http.patch(
        Uri.parse('$baseUrl/usuarios/password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'password_actual': passwordActual,
          'password_nueva': passwordNueva,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': data['mensaje'] ?? 'Error al cambiar la contraseña'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión. Verifica tu red.'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String email,
    required String telefono,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final response = await http.patch(
        Uri.parse('$baseUrl/usuarios/perfil'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'telefono': telefono,
        }),
      );

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        return {'success': false, 'message': 'Respuesta inválida del servidor (${response.statusCode})'};
      }

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['usuario']};
      } else {
        return {'success': false, 'message': data['mensaje'] ?? 'Error al actualizar perfil (${response.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
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