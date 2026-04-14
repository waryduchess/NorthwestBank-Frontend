import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bank_model.dart';
import '../models/beneficiary_model.dart';
import 'api_service.dart';

class TransferService {
  // TODO: Reemplazar esta data mock con llamada a API real cuando backend esté listo
  static const List<Map<String, dynamic>> _mockBanks = [
    {
      'id': 'bank_1',
      'nombre': 'BBVA México',
      'codigo': 'BBVAMX',
      'logo': null,
    },
    {
      'id': 'bank_2',
      'nombre': 'Citibanamex',
      'codigo': 'CITIMX',
      'logo': null,
    },
    {
      'id': 'bank_3',
      'nombre': 'Banco Azteca',
      'codigo': 'AZTECA',
      'logo': null,
    },
    {
      'id': 'bank_4',
      'nombre': 'Banorte',
      'codigo': 'BNORTE',
      'logo': null,
    },
    {
      'id': 'bank_5',
      'nombre': 'Santander México',
      'codigo': 'SANMX',
      'logo': null,
    },
    {
      'id': 'bank_6',
      'nombre': 'HSBC México',
      'codigo': 'HSBCMX',
      'logo': null,
    },
  ];

  static const List<Map<String, dynamic>> _mockBeneficiaries = [
    {
      'id': 'benef_1',
      'nombre': 'Juan Pérez',
      'numeroCuenta': '0102345678901',
      'banco': {
        'id': 'bank_1',
        'nombre': 'BBVA México',
        'codigo': 'BBVAMX',
        'logo': null,
      },
      'tipoTransferencia': 'inter-banco',
    },
  ];

  static Future<List<BankModel>> getBanks() async {
    try {
      // BACKEND: Descomentar cuando API esté lista
      // final response = await http.get(
      //   Uri.parse('${ApiService.baseUrl}/transferencias/bancos'),
      // );
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   final List<dynamic> banks = data['data'] ?? [];
      //   return banks.map((b) => BankModel.fromJson(b)).toList();
      // }
      // return [];

      // POR AHORA: Devolver mock data
      return _mockBanks.map((b) => BankModel.fromJson(b)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<BeneficiaryModel>> getBeneficiaries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      // BACKEND: Descomentar cuando API esté lista
      // final response = await http.get(
      //   Uri.parse('${ApiService.baseUrl}/transferencias/beneficiarios'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   final List<dynamic> beneficiaries = data['data'] ?? [];
      //   return beneficiaries.map((b) => BeneficiaryModel.fromJson(b)).toList();
      // }
      // return [];

      // POR AHORA: Devolver mock data
      return _mockBeneficiaries.map((b) => BeneficiaryModel.fromJson(b)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addBeneficiary({
    required String nombre,
    required String numeroCuenta,
    required String bankId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      // BACKEND: Descomentar cuando API esté lista
      // final response = await http.post(
      //   Uri.parse('${ApiService.baseUrl}/transferencias/beneficiarios'),
      //   headers: {
      //     'Authorization': 'Bearer $token',
      //     'Content-Type': 'application/json',
      //   },
      //   body: jsonEncode({
      //     'nombre': nombre,
      //     'numeroCuenta': numeroCuenta,
      //     'bankId': bankId,
      //   }),
      // );
      // return response.statusCode == 201;

      // POR AHORA: Solo retornar true
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> processTransfer({
    required String cuentaOrigen,
    required String monto,
    required String descripcion,
    String? cuentaDestino, // Para transferencias entre cuentas propias
    String? beneficiarioId, // Para transferencias a terceros
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      // BACKEND: Descomentar cuando API esté lista
      // final response = await http.post(
      //   Uri.parse('${ApiService.baseUrl}/transferencias/procesar'),
      //   headers: {
      //     'Authorization': 'Bearer $token',
      //     'Content-Type': 'application/json',
      //   },
      //   body: jsonEncode({
      //     'cuentaOrigen': cuentaOrigen,
      //     'cuentaDestino': cuentaDestino,
      //     'beneficiarioId': beneficiarioId,
      //     'monto': monto,
      //     'descripcion': descripcion,
      //   }),
      // );
      //
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   return {'success': true, 'data': data};
      // } else {
      //   final data = jsonDecode(response.body);
      //   return {'success': false, 'message': data['mensaje'] ?? 'Error al procesar transferencia'};
      // }

      // POR AHORA: Solo retornar success
      return {
        'success': true,
        'data': {
          'monto': monto,
          'mensaje': 'Transferencia realizada correctamente',
        }
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión. Verifica tu red.'};
    }
  }
}
