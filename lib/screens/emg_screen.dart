import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EMGScreen extends StatefulWidget {
  final Map<String, dynamic> datos;

  const EMGScreen({super.key, required this.datos});

  @override
  State<EMGScreen> createState() => _EMGScreenState();
}

class _EMGScreenState extends State<EMGScreen> {
  final List<FlSpot> _emg1 = List.generate(50, (i) => FlSpot(i.toDouble(), 0));
  final List<FlSpot> _emg2 = List.generate(50, (i) => FlSpot(i.toDouble(), 0));
  int _tick = 0;

  @override
  void didUpdateWidget(EMGScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.datos.isNotEmpty) {
      _actualizarGraficos();
    }
  }

  void _actualizarGraficos() {
    final emg1 = (widget.datos['emg1'] ?? 0).toDouble();
    final emg2 = (widget.datos['emg2'] ?? 0).toDouble();

    // Normalizar entre -1 y 1
    final emg1Norm = (emg1 / 4095 * 2 - 1);
    final emg2Norm = (emg2 / 4095 * 2 - 1);

    setState(() {
      _emg1.removeAt(0);
      _emg1.add(FlSpot(_tick.toDouble(), emg1Norm));
      _emg2.removeAt(0);
      _emg2.add(FlSpot(_tick.toDouble(), emg2Norm));

      // Reindexar
      for (int i = 0; i < _emg1.length; i++) {
        _emg1[i] = FlSpot(i.toDouble(), _emg1[i].y);
        _emg2[i] = FlSpot(i.toDouble(), _emg2[i].y);
      }
      _tick++;
    });
  }

  double get _bateria => (widget.datos['bateria'] ?? 0).toDouble();
  bool get _senialOk => widget.datos['senial_ok'] ?? false;
  String get _modo => widget.datos['modo'] ?? 'sin conexion';

  Color get _bateriaColor {
    if (_bateria > 50) return const Color(0xFF52B788);
    if (_bateria > 20) return Colors.orange;
    return Colors.red;
  }

  Widget _buildBateria() {
    return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            const Text('Bateria',
            style: TextStyle(color: Colors.white70, fontSize: 13)),
        Row(
            children: [
        Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
            color: _senialOk
            ? Colors.greenAccent.withOpacity(0.2)
            : Colors.redAccent.withOpacity(0.2),
    borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
    _senialOk ? 'Senal OK' : 'Sin senal',
    style: TextStyle(
    color: _senialOk ? Colors.greenAccent : Colors.redAccent,
    fontSize: 10,
    ),
    ),
    ),
    const SizedBox(width: 8),
    Text('${_bateria.toInt()}%',
    style: TextStyle(
    color: _bateriaColor,
    fontWeight: FontWeight.bold)),
    ],
    ),
    ],
    ),
    const SizedBox(height: 6),
    ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: LinearProgressIndicator(
    value: _bateria / 100,
    minHeight: 10,
    backgroundColor: Colors.grey[800],
    valueColor: AlwaysStoppedAnimation<Color>(_bateriaColor),
    ),
    ),
    ],
    ),
    );
  }

  Widget _buildGrafico(String titulo, List<FlSpot> spots, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                minY: -1,
                maxY: 1,
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: Colors.grey[800]!, strokeWidth: 1),
                  getDrawingVerticalLine: (_) =>
                      FlLine(color: Colors.grey[800]!, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telemetria EMG'),
        backgroundColor: const Color(0xFF2D6A4F),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBateria(),
            _buildGrafico('Canal EMG 1', _emg1, const Color(0xFF52B788)),
            _buildGrafico('Canal EMG 2', _emg2, const Color(0xFF95D5B2)),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetrica('Estado',
                      _senialOk ? 'Activo' : 'Sin senal',
                      _senialOk ? Colors.greenAccent : Colors.grey),
                  _buildMetrica('Modo', _modo, const Color(0xFF52B788)),
                  _buildMetrica('EMG',
                      widget.datos['emg1']?.toString() ?? '--',
                      const Color(0xFF95D5B2)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMetrica(String label, String valor, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(valor,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ],
    );
  }
}