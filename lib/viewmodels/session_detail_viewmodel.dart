import 'package:flutter/foundation.dart';
import '../data/measurement_repository.dart';
import '../models/measurement_sample.dart';
import '../models/measurement_session.dart';

class SessionDetailViewModel extends ChangeNotifier {
  final MeasurementRepository repo;
  final int sessionId;

  SessionDetailViewModel({required this.repo, required this.sessionId});

  bool loading = false;
  MeasurementSession? session;
  List<MeasurementSample> samples = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();

    session = await repo.getSession(sessionId);
    samples = await repo.getSamples(sessionId);

    loading = false;
    notifyListeners();
  }
}
