import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _mensajes = [];
  bool _cargando = false;

  final List<Map<String, String>> _faq = [
    {
      'pregunta': '¿Qué es el Proyecto Aurora?',
      'respuesta': 'Aurora es un brazo biónico controlado por señales EMG usando un ESP32 y servomotores para mover cada dedo individualmente.'
    },
    {
      'pregunta': '¿Qué son las señales EMG?',
      'respuesta': 'Las señales EMG (electromiografía) son señales eléctricas generadas por los músculos. El sensor las capta y el ESP32 las interpreta para mover los dedos.'
    },
    {
      'pregunta': '¿Cómo se conecta la app?',
      'respuesta': 'La app se conecta al ESP32 mediante WiFi usando WebSocket, lo que permite comunicación en tiempo real.'
    },
    {
      'pregunta': '¿Cómo calibro el sensor EMG?',
      'respuesta': 'Colocá el sensor en el antebrazo, relajá el músculo para establecer la línea base, y luego contraé para definir el umbral de activación.'
    },
  ];

  Future<void> _enviar(String texto) async {
    if (texto.trim().isEmpty) return;

    setState(() {
      _mensajes.add({'rol': 'usuario', 'texto': texto});
      _cargando = true;
    });
    _controller.clear();

    final respuesta = await AIService.enviarMensaje(texto);

    setState(() {
      _mensajes.add({'rol': 'ia', 'texto': respuesta});
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Aurora'),
        backgroundColor: const Color(0xFF2D6A4F),
      ),
      body: Column(
        children: [
          // FAQ
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[900],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 6),
                  child: Text('Preguntas frecuentes',
                      style: TextStyle(
                          color: Color(0xFF2D6A4F),
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _faq.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ActionChip(
                        label: Text(_faq[index]['pregunta']!,
                            style: const TextStyle(fontSize: 12)),
                        onPressed: () =>
                            _enviar(_faq[index]['pregunta']!),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Mensajes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _mensajes.length + (_cargando ? 1 : 0),
              itemBuilder: (context, index) {
                if (_cargando && index == _mensajes.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final msg = _mensajes[index];
                final esUsuario = msg['rol'] == 'usuario';
                return Align(
                  alignment: esUsuario
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth:
                        MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: esUsuario
                          ? const Color(0xFF2D6A4F)
                          : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['texto']!,
                        style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[900],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Preguntá algo sobre Aurora...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: _enviar,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF2D6A4F)),
                  onPressed: () => _enviar(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}