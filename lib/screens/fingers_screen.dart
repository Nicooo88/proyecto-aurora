import 'package:flutter/material.dart';

class FingersScreen extends StatefulWidget {
  const FingersScreen({super.key});

  @override
  State<FingersScreen> createState() => _FingersScreenState();
}

class _FingersScreenState extends State<FingersScreen> {
  Map<String, bool> _dedos = {
    'pulgar': false,
    'indice': false,
    'medio': false,
    'anular': false,
    'menique': false,
  };

  String _accionActiva = '';

  void _aplicarAccion(String accion) {
    setState(() {
      _accionActiva = accion;
      switch (accion) {
        case 'like':
          _dedos = {'pulgar': true, 'indice': false, 'medio': false, 'anular': false, 'menique': false};
          break;
        case 'paz':
          _dedos = {'pulgar': false, 'indice': true, 'medio': true, 'anular': false, 'menique': false};
          break;
        case 'pinza':
          _dedos = {'pulgar': true, 'indice': true, 'medio': false, 'anular': false, 'menique': false};
          break;
        case 'puno':
          _dedos = {'pulgar': false, 'indice': false, 'medio': false, 'anular': false, 'menique': false};
          break;
        case 'abierta':
          _dedos = {'pulgar': true, 'indice': true, 'medio': true, 'anular': true, 'menique': true};
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Dedos'),
        backgroundColor: const Color(0xFF2D6A4F),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _buildMano(),
            ),
          ),
          _buildPanel(),
        ],
      ),
    );
  }

  Widget _buildMano() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Estado de la mano',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildDedo('pulgar', 40, 60),
              const SizedBox(width: 6),
              _buildDedo('indice', 50, 90),
              const SizedBox(width: 6),
              _buildDedo('medio', 50, 100),
              const SizedBox(width: 6),
              _buildDedo('anular', 50, 85),
              const SizedBox(width: 6),
              _buildDedo('menique', 40, 65),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: 160,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _dedos.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Icon(
                      e.value ? Icons.circle : Icons.circle_outlined,
                      color: e.value ? const Color(0xFF52B788) : Colors.grey,
                      size: 12,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.key[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDedo(String nombre, double ancho, double alto) {
    final extendido = _dedos[nombre] ?? false;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: ancho.toDouble(),
      height: extendido ? alto.toDouble() : alto * 0.4,
      decoration: BoxDecoration(
        color: extendido ? const Color(0xFF52B788) : Colors.grey[700],
        borderRadius: BorderRadius.circular(12),
        boxShadow: extendido
            ? [BoxShadow(color: const Color(0xFF52B788).withOpacity(0.4), blurRadius: 8)]
            : [],
      ),
    );
  }

  Widget _buildPanel() {
    final acciones = [
      {'id': 'like', 'label': 'Like', 'icon': Icons.thumb_up},
      {'id': 'paz', 'label': 'Paz', 'icon': Icons.sign_language},
      {'id': 'pinza', 'label': 'Pinza', 'icon': Icons.pinch},
      {'id': 'puno', 'label': 'Puño', 'icon': Icons.back_hand},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Acciones rápidas',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: acciones.map((a) {
              final activo = _accionActiva == a['id'];
              return GestureDetector(
                onTap: () => _aplicarAccion(a['id'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: activo ? const Color(0xFF2D6A4F) : Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: activo ? const Color(0xFF52B788) : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(a['icon'] as IconData,
                          color: activo ? Colors.white : Colors.white54,
                          size: 24),
                      const SizedBox(height: 4),
                      Text(a['label'] as String,
                          style: TextStyle(
                              color: activo ? Colors.white : Colors.white54,
                              fontSize: 11)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}