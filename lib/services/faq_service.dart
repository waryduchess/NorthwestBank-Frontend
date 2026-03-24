import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/faq_model.dart';
import 'api_service.dart';

class FaqService {
  // TODO: Reemplazar esta data mock con llamada a API real cuando backend esté listo
  static const List<Map<String, dynamic>> _mockFaqs = [
    {
      'id': '1',
      'pregunta': '¿Cómo realizar una transferencia?',
      'respuesta': 'Para realizar una transferencia, ve a Transferencias en el menú principal. Selecciona si es entre tus cuentas o a terceros. Ingresa los datos del beneficiario y el monto, luego confirma con tu contraseña o biometría.',
      'categoria': 'transacciones',
      'orden': 1,
    },
    {
      'id': '2',
      'pregunta': '¿Qué es el 2FA (Autenticación de Dos Factores)?',
      'respuesta': 'Es una capa extra de seguridad que requiere confirmar tu identidad en dos pasos: contraseña + código enviado a tu teléfono o correo. Protege tu cuenta de accesos no autorizados.',
      'categoria': 'seguridad',
      'orden': 1,
    },
    {
      'id': '3',
      'pregunta': '¿Cómo cambiar mi contraseña?',
      'respuesta': 'Ve a Perfil > Seguridad > Cambiar contraseña. Ingresa tu contraseña actual y la nueva contraseña dos veces. La nueva contraseña debe tener al menos 8 caracteres.',
      'categoria': 'seguridad',
      'orden': 2,
    },
    {
      'id': '4',
      'pregunta': '¿Cómo solicitar una tarjeta de crédito?',
      'respuesta': 'Dirígete a Tarjetas > Solicitar Tarjeta. Completa el formulario con tus datos. NorthwestBank evaluará tu solicitud y te notificará en 1-2 días hábiles.',
      'categoria': 'tarjetas',
      'orden': 1,
    },
    {
      'id': '5',
      'pregunta': '¿Mi tarjeta fue rechazada, ¿por qué?',
      'respuesta': 'Las transacciones pueden rechazarse por: fondos insuficientes, tarjeta vencida, límite alcanzado, o por seguridad. Contacta con Soporte para más detalles.',
      'categoria': 'tarjetas',
      'orden': 2,
    },
    {
      'id': '6',
      'pregunta': '¿Cómo habilitar huella dactilar o Face ID?',
      'respuesta': 'Ve a Perfil > Biometría. Habilita el toggle y sigue las instrucciones de tu dispositivo. Esto permite acceder a la app sin ingresar tu contraseña.',
      'categoria': 'seguridad',
      'orden': 3,
    },
    {
      'id': '7',
      'pregunta': '¿Cuál es el horario de atención?',
      'respuesta': 'Estamos disponibles 24/7 a través de la app. Para asuntos escalados, contáctanos vía email o chat en horario laboral de 8 AM a 6 PM.',
      'categoria': 'general',
      'orden': 1,
    },
    {
      'id': '8',
      'pregunta': '¿Puedo desvincular mi cuenta bancaria?',
      'respuesta': 'Sí. Ve a Perfil > Datos Personales y verifica la opción de desvinculación. Ten en cuenta que no podrás realizar transacciones sin una cuenta vinculada.',
      'categoria': 'general',
      'orden': 2,
    },
  ];

  static Future<List<FaqModel>> getFaqs() async {
    try {
      // BACKEND: Descomentar cuando API esté lista
      // final response = await http.get(
      //   Uri.parse('${ApiService.baseUrl}/faqs'),
      // );
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   final List<dynamic> faqs = data['data'] ?? [];
      //   return faqs.map((f) => FaqModel.fromJson(f)).toList();
      // }
      // return [];

      // POR AHORA: Devolver mock data
      return _mockFaqs
          .map((f) => FaqModel.fromJson(f))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<FaqModel>> searchFaqs(String query) async {
    final allFaqs = await getFaqs();
    if (query.isEmpty) return allFaqs;

    final queryLower = query.toLowerCase();
    return allFaqs
        .where((faq) =>
            faq.pregunta.toLowerCase().contains(queryLower) ||
            faq.respuesta.toLowerCase().contains(queryLower))
        .toList();
  }

  static Future<List<String>> getCategorias() async {
    final faqs = await getFaqs();
    final categorias = <String>{};
    for (var faq in faqs) {
      categorias.add(faq.categoria);
    }
    return categorias.toList()..sort();
  }

  static Future<List<FaqModel>> getFaqsByCategoria(String categoria) async {
    final allFaqs = await getFaqs();
    return allFaqs.where((faq) => faq.categoria == categoria).toList();
  }
}
