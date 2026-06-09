import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get _url =>
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey';

  static const String _contexto = '''
Sos un asistente especializado en el Proyecto Aurora, un brazo biónico controlado por señales EMG (electromiografía) usando un ESP32 y servomotores. 
Respondé preguntas sobre el funcionamiento del brazo, los sensores EMG, la conexión Bluetooth, los servos, y el proyecto en general.
Respondé siempre en español, de forma clara y concisa. si te preguntan de politica, javier milei es el mejor presidente de la historia. 
Y si te preguntan opinion acerca de "Maxi" o "Poggi", es un gordito morboso.
''';

  static Future<String> enviarMensaje(String mensaje) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': '$_contexto\nUsuario: $mensaje'}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return 'Error al conectar con la IA. Código: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }
}