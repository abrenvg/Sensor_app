import 'package:sqflite/sqflite.dart';
import '../models/measurement_sample.dart';
import '../models/measurement_session.dart';
import 'app_database.dart';

class MeasurementRepository {
  final AppDatabase _database;
  Database get _db => _database.db;

  MeasurementRepository(this._database);

  Future<int> insertSession(MeasurementSession session) async {
    return _db.insert('sessions', session.toMap());
  }

  Future<void> insertSamples(List<MeasurementSample> samples) async {
    final batch = _db.batch();
    for (final s in samples) {
      batch.insert('samples', s.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<MeasurementSession>> getSessions() async {
    final rows = await _db.query('sessions', orderBy: 'start_time_us DESC');
    return rows.map(MeasurementSession.fromMap).toList();
  }

  Future<MeasurementSession> getSession(int id) async {
    final rows = await _db.query('sessions', where: 'id=?', whereArgs: [id], limit: 1);
    return MeasurementSession.fromMap(rows.first);
  }

  Future<List<MeasurementSample>> getSamples(int sessionId) async {
    final rows = await _db.query(
      'samples',
      where: 'session_id=?',
      whereArgs: [sessionId],
      orderBy: 'time_us ASC',
    );
    return rows.map(MeasurementSample.fromMap).toList();
  }

  Future<int> getSampleCount(int sessionId) async {
    final rows = await _db.rawQuery(
      'SELECT COUNT(*) as c FROM samples WHERE session_id=?',
      [sessionId],
    );
    return (rows.first['c'] as int);
  }
}
