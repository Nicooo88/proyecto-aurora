import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EMGScreen extends StatefulWidget {
  const EMGScreen({super.key});

  @override
  State<EMGScreen> createState() => _EMGScreenState();
}

class _EMGScreenState extends State<EMGScreen> {
  double _bateria = 78;

  final List<FlSpot> _emg1 = List.generate(20, (i) => FlSpot(i.toDouble(), 0));
  final List<FlSpot> _emg2 = List.generate(20, (i) => FlSpot(i.toDouble(), 0));

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
              const Text('Batería',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text('${_bateria.toInt()}%',
                  style: TextStyle(
                      color: _bateriaColor, fontWeight: FontWeight.bold)),
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
        title: const Text('Telemetría EMG'),
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
                  _buildMetrica('Estado', 'Sin señal', Colors.grey),
                  _buildMetrica('Frecuencia', '-- Hz', const Color(0xFF52B788)),
                  _buildMetrica('Amplitud', '-- mV', const Color(0xFF95D5B2)),
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
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}