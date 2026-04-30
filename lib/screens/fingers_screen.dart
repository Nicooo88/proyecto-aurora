import 'package:flutter/material.dart';

class FingersScreen extends StatefulWidget {
  final Map<String, dynamic> datos;
  final Function(String, {int? angulo}) onAccion;

  const FingersScreen({
    super.key,
    required this.datos,
    required this.onAccion,
  });

  @override
  State<FingersScreen> createState() => _FingersScreenState();
}

class _FingersScreenState extends State<FingersScreen> {
  Map<String, bool> _dedos = {
    'pulgar': true,
    'indice': true,
    'medio': true,
    'anular': true,
    'menique': true,
  };

  String _accionActiva = 'abierta';

  @override
  void didUpdateWidget(FingersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.datos.containsKey('dedos')) {
      final dedos = widget.datos['dedos'];
      setState(() {
        _dedos = {
          'pulgar': dedos['pulgar'] ?? false,
          'indice': dedos['indice'] ?? false,
          'medio': dedos['medio'] ?? false,
          'anular': dedos['anular'] ?? false,
          'menique': dedos['menique'] ?? false,
        };
      });
    }
  }

  void _aplicarAccion(String accion) {
    setState(() => _accionActiva = accion);
    widget.onAccion(accion);

    switch (accion) {
      case 'like':
        setState(() => _dedos = {'pulgar': true, 'indice': false, 'medio': false, 'anular': false, 'menique': false});
        break;
      case 'paz':
        setState(() => _dedos = {'pulgar': false, 'indice': true, 'medio': true, 'anular': false, 'menique': false});
        break;
      case 'pinza':
        setState(() => _dedos = {'pulgar': true, 'indice': true, 'medio': false, 'anular': false, 'menique': false});
        break;
      case 'puno':
        setState(() => _dedos = {'pulgar': false, 'indice': false, 'medio': false, 'anular': false, 'menique': false});
        break;
      case 'abierta':
        setState(() => _dedos = {'pulgar': true, 'indice': true, 'medio': true, 'anular': true, 'menique': true});
        break;
    }
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
          Expanded(child: Center(child: _buildMano())),
          _buildPanel(),
        ],
      ),
    );
  }

  Widget _buildMano() {
    final esPuno = _accionActiva == 'puno';

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _accionActiva == 'puno' ? 'Puno cerrado' :
            _accionActiva == 'like' ? 'Like' :
            _accionActiva == 'paz' ? 'Paz' :
            _accionActiva == 'pinza' ? 'Pinza' : 'Mano abierta',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.datos.containsKey('dedos')
                  ? Colors.greenAccent.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.datos.containsKey('dedos') ? 'Datos en tiempo real' : 'Modo manual',
              style: TextStyle(
                color: widget.datos.containsKey('dedos') ? Colors.greenAccent : Colors.white38,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildDedo('pulgar', 38, 55, esPuno),
              const SizedBox(width: 8),
              _buildDedo('indice', 44, 90, esPuno),
              const SizedBox(width: 8),
              _buildDedo('medio', 44, 100, esPuno),
              const SizedBox(width: 8),
              _buildDedo('anular', 44, 85, esPuno),
              const SizedBox(width: 8),
              _buildDedo('menique', 38, 65, esPuno),
            ],
          ),
          Container(
            width: 230,
            height: 55,
            decoration: BoxDecoration(
              color: esPuno ? Colors.red[900] : Colors.grey[800],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(
                color: esPuno
                    ? Colors.redAccent.withOpacity(0.5)
                    : Colors.grey[700]!,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                esPuno ? 'CERRADO' : 'ABIERTO',
                style: TextStyle(
                  color: esPuno ? Colors.redAccent : const Color(0xFF52B788),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _dedos.entries.map((e) {
              final activo = e.value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: esPuno
                            ? Colors.redAccent.withOpacity(0.6)
                            : activo
                            ? const Color(0xFF52B788)
                            : Colors.grey[700],
                        boxShadow: activo || esPuno ? [
                          BoxShadow(
                            color: esPuno
                                ? Colors.redAccent.withOpacity(0.4)
                                : const Color(0xFF52B788).withOpacity(0.6),
                            blurRadius: 6,
                          )
                        ] : [],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.key[0].toUpperCase(),
                      style: TextStyle(
                        color: activo || esPuno ? Colors.white60 : Colors.white24,
                        fontSize: 10,
                      ),
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

  Widget _buildDedo(String nombre, double ancho, double altoMax, bool esPuno) {
    final activo = _dedos[nombre] ?? false;
    final altura = esPuno ? altoMax * 0.3 : activo ? altoMax : altoMax * 0.3;
    final color = esPuno
        ? Colors.red[800]!
        : activo
        ? const Color(0xFF52B788)
        : Colors.grey[700]!;
    final glow = esPuno
        ? Colors.redAccent.withOpacity(0.4)
        : activo
        ? const Color(0xFF52B788).withOpacity(0.4)
        : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: ancho,
      height: altura,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(color: glow, blurRadius: 10, spreadRadius: 1),
        ],
      ),
    );
  }

  Widget _buildPanel() {
    final acciones = [
      {'id': 'abierta', 'label': 'Abierta', 'icon': Icons.pan_tool},
      {'id': 'like', 'label': 'Like', 'icon': Icons.thumb_up},
      {'id': 'paz', 'label': 'Paz', 'icon': Icons.sign_language},
      {'id': 'pinza', 'label': 'Pinza', 'icon': Icons.pinch},
      {'id': 'puno', 'label': 'Puno', 'icon': Icons.back_hand},
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
          const Text('Acciones rapidas',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: acciones.map((a) {
              final activo = _accionActiva == a['id'];
              final esPuno = a['id'] == 'puno';
              return GestureDetector(
                onTap: () => _aplicarAccion(a['id'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: activo
                        ? esPuno ? Colors.red[900] : const Color(0xFF2D6A4F)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: activo
                          ? esPuno ? Colors.redAccent : const Color(0xFF52B788)
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(a['icon'] as IconData,
                          color: activo
                              ? esPuno ? Colors.redAccent : const Color(0xFF52B788)
                              : Colors.white54,
                          size: 22),
                      const SizedBox(height: 4),
                      Text(a['label'] as String,
                          style: TextStyle(
                              color: activo
                                  ? esPuno ? Colors.redAccent : const Color(0xFF52B788)
                                  : Colors.white54,
                              fontSize: 10)),
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