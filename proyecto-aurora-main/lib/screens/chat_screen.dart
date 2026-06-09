import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _cargando = false;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  final List<Map<String, String>> _faq = [
    {
      'pregunta': '¿Que es el Proyecto Aurora?',
      'respuesta': 'Aurora es un brazo bionico controlado por senales EMG usando un ESP32 y servomotores para mover cada dedo individualmente.'
    },
    {
      'pregunta': '¿Que son las senales EMG?',
      'respuesta': 'Las senales EMG (electromiografia) son senales electricas generadas por los musculos. El sensor las capta y el ESP32 las interpreta para mover los dedos.'
    },
    {
      'pregunta': '¿Como se conecta la app?',
      'respuesta': 'La app se conecta al ESP32 mediante Bluetooth BLE, lo que permite comunicacion en tiempo real sin necesidad de WiFi.'
    },
    {
      'pregunta': '¿Como calibro el sensor EMG?',
      'respuesta': 'Coloca el sensor en el antebrazo, relaja el musculo para establecer la linea base, y luego contrae para definir el umbral de activacion.'
    },
  ];

  Future<void> _enviar(String texto) async {
    if (texto.trim().isEmpty || _uid == null) return;

    setState(() => _cargando = true);
    _controller.clear();

    // Guardar mensaje usuario en Firestore
    await _db.collection('chats').doc(_uid).collection('mensajes').add({
      'rol': 'usuario',
      'texto': texto,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final respuesta = await AIService.enviarMensaje(texto);

    // Guardar respuesta IA en Firestore
    await _db.collection('chats').doc(_uid).collection('mensajes').add({
      'rol': 'ia',
      'texto': respuesta,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() => _cargando = false);
  }

  Future<void> _limpiarChat() async {
    if (_uid == null) return;
    final mensajes = await _db
        .collection('chats')
        .doc(_uid)
        .collection('mensajes')
        .get();
    for (var doc in mensajes.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Aurora'),
        backgroundColor: const Color(0xFF2D6A4F),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: const Text('Limpiar chat',
                      style: TextStyle(color: Colors.white)),
                  content: const Text(
                      '¿Eliminar todo el historial de chat?',
                      style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar',
                          style: TextStyle(color: Colors.white38)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
              if (confirmar == true) await _limpiarChat();
            },
          ),
        ],
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
                          color: Color(0xFF52B788),
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
                        onPressed: () => _enviar(_faq[index]['pregunta']!),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Mensajes desde Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _uid == null
                  ? null
                  : _db
                  .collection('chats')
                  .doc(_uid)
                  .collection('mensajes')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF52B788)),
                  );
                }

                final mensajes = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: mensajes.length + (_cargando ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_cargando && index == mensajes.length) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                              color: Color(0xFF52B788)),
                        ),
                      );
                    }

                    final msg = mensajes[index].data() as Map<String, dynamic>;
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
                        child: Text(msg['texto'] ?? '',
                            style:
                            const TextStyle(color: Colors.white)),
                      ),
                    );
                  },
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
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Pregunta algo sobre Aurora...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: _enviar,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send,
                      color: Color(0xFF52B788)),
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