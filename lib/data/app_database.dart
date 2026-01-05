import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  final Database db;
  AppDatabase._(this.db);

  static Future<AppDatabase> create() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'shoulder_measurements.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE sessions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            start_time_us INTEGER NOT NULL,
            end_time_us INTEGER NOT NULL
          );
        ''');

        await db.execute('''
          CREATE TABLE samples(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL,
            time_us INTEGER NOT NULL,
            angle1_deg REAL NOT NULL,
            angle2_deg REAL NOT NULL,
            FOREIGN KEY(session_id) REFERENCES sessions(id) ON DELETE CASCADE
          );
        ''');

        await db.execute('CREATE INDEX idx_samples_session_id ON samples(session_id);');
      },
    );

    return AppDatabase._(db);
  }
}
