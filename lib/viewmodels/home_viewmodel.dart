import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/measurement_repository.dart';
import '../models/measurement_sample.dart';
import '../models/measurement_session.dart';
import '../services/sensor_fusion_service.dart';

class ChartPoint {
  final int timeUs;
  final double a1;
  final double a2;
  ChartPoint(this.timeUs, this.a1, this.a2);
}

class HomeViewModel extends ChangeNotifier {
  final MeasurementRepository repo;
  final SensorFusionService sensors;

  HomeViewModel({required this.repo, required this.sensors});

  bool isRecording = false;

  int? _startUs;
  int? lastSavedSessionId;

  final List<ChartPoint> points = [];
  StreamSubscription<FusedAngles>? _sub;

  // show on UI
  double lastAlgo1 = 0;
  double lastAlgo2 = 0;

  // Allow user to tweak alphas
  double get ewmaAlpha => sensors.ewmaAlpha;
  double get compAlpha => sensors.compAlpha;

  void setEwmaAlpha(double v) {
    sensors.ewmaAlpha = v;
    notifyListeners();
  }

  void setCompAlpha(double v) {
    sensors.compAlpha = v;
    notifyListeners();
  }

  Future<void> start() async {
    if (isRecording) return;

    points.clear();
    lastSavedSessionId = null;
    _startUs = DateTime.now().microsecondsSinceEpoch;

    await sensors.start();
    _sub = sensors.stream.listen((fa) {
      points.add(ChartPoint(fa.timeUs, fa.algo1Deg, fa.algo2Deg));
      lastAlgo1 = fa.algo1Deg;
      lastAlgo2 = fa.algo2Deg;
      notifyListeners();
    });

    isRecording = true;
    notifyListeners();
  }

  Future<void> stop() async {
    if (!isRecording) return;

    await _sub?.cancel();
    _sub = null;
    await sensors.stop();

    isRecording = false;

    // Save to DB
    final endUs = DateTime.now().microsecondsSinceEpoch;
    final startUs = _startUs ?? endUs;

    final sessionId = await repo.insertSession(
      MeasurementSession(startTimeUs: startUs, endTimeUs: endUs),
    );

    final samples = points
        .map((p) => MeasurementSample(
      sessionId: sessionId,
      timeUs: p.timeUs,
      angleAlgo1Deg: p.a1,
      angleAlgo2Deg: p.a2,
    ))
        .toList();

    await repo.insertSamples(samples);

    lastSavedSessionId = sessionId;
    notifyListeners();
  }

  Future<void> exportCurrentCsv() async {
    if (points.isEmpty) return;

    final start = _startUs ?? points.first.timeUs;
    final csv = _buildCsvFromPoints(points);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/measurement_${start}.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: 'Shoulder elevation measurement CSV');
  }

  Future<void> exportSessionCsv(int sessionId) async {
    final samples = await repo.getSamples(sessionId);
    if (samples.isEmpty) return;

    final rows = <String>[];
    rows.add('timestamp_iso,timestamp_us,angle_algo1_deg,angle_algo2_deg');
    for (final s in samples) {
      final iso = DateTime.fromMicrosecondsSinceEpoch(s.timeUs).toIso8601String();
      rows.add('$iso,${s.timeUs},${s.angleAlgo1Deg.toStringAsFixed(4)},${s.angleAlgo2Deg.toStringAsFixed(4)}');
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/measurement_session_$sessionId.csv');
    await file.writeAsString(rows.join('\n'));

    await Share.shareXFiles([XFile(file.path)], text: 'Saved measurement CSV (session $sessionId)');
  }

  String _buildCsvFromPoints(List<ChartPoint> pts) {
    final rows = <String>[];
    rows.add('timestamp_iso,timestamp_us,angle_algo1_deg,angle_algo2_deg');
    for (final p in pts) {
      final iso = DateTime.fromMicrosecondsSinceEpoch(p.timeUs).toIso8601String();
      rows.add('$iso,${p.timeUs},${p.a1.toStringAsFixed(4)},${p.a2.toStringAsFixed(4)}');
    }
    return rows.join('\n');
  }

  @override
  void dispose() {
    _sub?.cancel();
    sensors.dispose();
    super.dispose();
  }
}
