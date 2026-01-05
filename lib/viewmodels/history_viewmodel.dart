import 'package:flutter/foundation.dart';
import '../data/measurement_repository.dart';
import '../models/measurement_session.dart';

class HistoryViewModel extends ChangeNotifier {
  final MeasurementRepository repo;
  HistoryViewModel({required this.repo});

  bool loading = false;
  List<MeasurementSession> sessions = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();

    sessions = await repo.getSessions();

    loading = false;
    notifyListeners();
  }
}
