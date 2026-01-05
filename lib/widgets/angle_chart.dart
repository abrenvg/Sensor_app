import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../viewmodels/home_viewmodel.dart';
import '../models/measurement_sample.dart';

class AngleChart extends StatelessWidget {
  final List<ChartPoint>? livePoints;
  final List<MeasurementSample>? dbSamples;

  const AngleChart.live({super.key, required this.livePoints}) : dbSamples = null;
  const AngleChart.saved({super.key, required this.dbSamples}) : livePoints = null;

  @override
  Widget build(BuildContext context) {
    final pts = livePoints;
    final samples = dbSamples;

    if ((pts == null || pts.isEmpty) && (samples == null || samples.isEmpty)) {
      return const Center(child: Text("No data yet"));
    }

    final x0 = (pts != null)
        ? pts.first.timeUs.toDouble()
        : samples!.first.timeUs.toDouble();

    List<FlSpot> s1;
    List<FlSpot> s2;

    if (pts != null) {
      s1 = pts.map((p) => FlSpot((p.timeUs.toDouble() - x0) / 1e6, p.a1)).toList();
      s2 = pts.map((p) => FlSpot((p.timeUs.toDouble() - x0) / 1e6, p.a2)).toList();
    } else {
      s1 = samples!.map((p) => FlSpot((p.timeUs.toDouble() - x0) / 1e6, p.angleAlgo1Deg)).toList();
      s2 = samples.map((p) => FlSpot((p.timeUs.toDouble() - x0) / 1e6, p.angleAlgo2Deg)).toList();
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 120,
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: s1,
            isCurved: false,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: s2,
            isCurved: false,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
