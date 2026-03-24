import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment_category_model.dart';
import '../models/payment_subcategory_model.dart';
import '../models/payment_service_model.dart';
import 'api_service.dart';

class PaymentService {
  // TODO: Reemplazar esta data mock con llamada a API real cuando backend esté listo
  static const List<Map<String, dynamic>> _mockCategories = [
    {
      'id': 'cat_1',
      'nombre': 'Electricidad',
      'icono': 'bolt',
      'orden': 1,
    },
    {
      'id': 'cat_2',
      'nombre': 'Agua',
      'icono': 'water',
      'orden': 2,
    },
    {
      'id': 'cat_3',
      'nombre': 'Internet',
      'icono': 'wifi',
      'orden': 3,
    },
    {
      'id': 'cat_4',
      'nombre': 'Telefonía',
      'icono': 'phone',
      'orden': 4,
    },
    {
      'id': 'cat_5',
      'nombre': 'Cable TV',
      'icono': 'tv',
      'orden': 5,
    },
    {
      'id': 'cat_6',
      'nombre': 'Gas',
      'icono': 'local_gas_station',
      'orden': 6,
    },
  ];

  static const List<Map<String, dynamic>> _mockSubcategories = [
    // Electricidad - CFE
    {
      'id': 'subcat_1',
      'categoryId': 'cat_1',
      'nombre': 'CFE - Comisión Federal de Electricidad',
      'codigo': 'CFE',
      'orden': 1,
    },
    // Agua - Aguakan
    {
      'id': 'subcat_2',
      'categoryId': 'cat_2',
      'nombre': 'Aguakan',
      'codigo': 'AGUAKAN',
      'orden': 1,
    },
    {
      'id': 'subcat_3',
      'categoryId': 'cat_2',
      'nombre': 'Sistema de Agua Potable CDMX',
      'codigo': 'SAPCX',
      'orden': 2,
    },
    // Internet - Telmex/Infinitum
    {
      'id': 'subcat_4',
      'categoryId': 'cat_3',
      'nombre': 'Infinitum (Telmex)',
      'codigo': 'INFINITUM',
      'orden': 1,
    },
    {
      'id': 'subcat_5',
      'categoryId': 'cat_3',
      'nombre': 'Axtel',
      'codigo': 'AXTEL',
      'orden': 2,
    },
    {
      'id': 'subcat_6',
      'categoryId': 'cat_3',
      'nombre': 'Megacable',
      'codigo': 'MEGACABLE',
      'orden': 3,
    },
    {
      'id': 'subcat_7',
      'categoryId': 'cat_3',
      'nombre': 'Izzi',
      'codigo': 'IZZI',
      'orden': 4,
    },
    // Telefonía - Telcel
    {
      'id': 'subcat_8',
      'categoryId': 'cat_4',
      'nombre': 'Telcel',
      'codigo': 'TELCEL',
      'orden': 1,
    },
    {
      'id': 'subcat_9',
      'categoryId': 'cat_4',
      'nombre': 'Movistar',
      'codigo': 'MOVISTAR',
      'orden': 2,
    },
    {
      'id': 'subcat_10',
      'categoryId': 'cat_4',
      'nombre': 'AT&T',
      'codigo': 'ATT',
      'orden': 3,
    },
    {
      'id': 'subcat_11',
      'categoryId': 'cat_4',
      'nombre': 'Virgin Mobile',
      'codigo': 'VIRGIN',
      'orden': 4,
    },
    {
      'id': 'subcat_12',
      'categoryId': 'cat_4',
      'nombre': 'Unefon',
      'codigo': 'UNEFON',
      'orden': 5,
    },
    // Cable TV
    {
      'id': 'subcat_13',
      'categoryId': 'cat_5',
      'nombre': 'Sky',
      'codigo': 'SKY',
      'orden': 1,
    },
    {
      'id': 'subcat_14',
      'categoryId': 'cat_5',
      'nombre': 'Cablevición',
      'codigo': 'CABLEVISION',
      'orden': 2,
    },
    {
      'id': 'subcat_15',
      'categoryId': 'cat_5',
      'nombre': 'Axtel TV',
      'codigo': 'AXTELTV',
      'orden': 3,
    },
    // Gas
    {
      'id': 'subcat_16',
      'categoryId': 'cat_6',
      'nombre': 'Gas Cuauhtémoc',
      'codigo': 'GASCUA',
      'orden': 1,
    },
    {
      'id': 'subcat_17',
      'categoryId': 'cat_6',
      'nombre': 'Flamagas',
      'codigo': 'FLAMAGAS',
      'orden': 2,
    },
  ];

  static const List<Map<String, dynamic>> _mockServices = [
    // Servicios generales (placeholder)
    {
      'id': 'srv_1',
      'subcategoryId': 'subcat_1',
      'nombre': 'Pago de Recibo',
      'codigo': 'PAGO_REC',
      'requiereReferencia': true,
    },
  ];

  static Future<List<PaymentCategoryModel>> getCategories() async {
    try {
      // BACKEND: Descomentar cuando API esté lista
      // final response = await http.get(
      //   Uri.parse('${ApiService.baseUrl}/pagos/categorias'),
      // );
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   final List<dynamic> cats = data['data'] ?? [];
      //   return cats.map((c) => PaymentCategoryModel.fromJson(c)).toList();
      // }
      // return [];

      // POR AHORA: Devolver mock data
      return _mockCategories
          .map((c) => PaymentCategoryModel.fromJson(c))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<PaymentSubcategoryModel>> getSubcategories(String categoryId) async {
    try {
      // BACKEND: Descomentar cuando API esté lista
      // final response = await http.get(
      //   Uri.parse('${ApiService.baseUrl}/pagos/categorias/$categoryId/subcategorias'),
      // );
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   final List<dynamic> subcats = data['data'] ?? [];
      //   return subcats.map((s) => PaymentSubcategoryModel.fromJson(s)).toList();
      // }
      // return [];

      // POR AHORA: Devolver mock data filtrada
      return _mockSubcategories
          .where((s) => s['categoryId'] == categoryId)
          .map((s) => PaymentSubcategoryModel.fromJson(s))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<PaymentServiceModel>> getServices(String subcategoryId) async {
    try {
      // BACKEND: Descomentar cuando API esté lista
      // final response = await http.get(
      //   Uri.parse('${ApiService.baseUrl}/pagos/servicios/$subcategoryId'),
      // );
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   final List<dynamic> services = data['data'] ?? [];
      //   return services.map((srv) => PaymentServiceModel.fromJson(srv)).toList();
      // }
      // return [];

      // POR AHORA: Devolver mock data
      return _mockServices
          .where((s) => s['subcategoryId'] == subcategoryId)
          .map((s) => PaymentServiceModel.fromJson(s))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> processPayment({
    required String serviceId,
    required String referencia,
    required String monto,
    required String cuentaDebito,
    String? descripcion,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      // BACKEND: Descomentar cuando API esté lista
      // final response = await http.post(
      //   Uri.parse('${ApiService.baseUrl}/pagos/procesar'),
      //   headers: {
      //     'Authorization': 'Bearer $token',
      //     'Content-Type': 'application/json',
      //   },
      //   body: jsonEncode({
      //     'serviceId': serviceId,
      //     'referencia': referencia,
      //     'monto': monto,
      //     'cuentaDebito': cuentaDebito,
      //     'descripcion': descripcion,
      //   }),
      // );
      //
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   return {'success': true, 'data': data};
      // } else {
      //   final data = jsonDecode(response.body);
      //   return {'success': false, 'message': data['mensaje'] ?? 'Error al procesar pago'};
      // }

      // POR AHORA: Solo retornar success
      return {
        'success': true,
        'data': {
          'referencia': referencia,
          'monto': monto,
          'mensaje': 'Pago procesado correctamente',
        }
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión. Verifica tu red.'};
    }
  }
}
