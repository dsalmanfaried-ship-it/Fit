import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/workout.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'fitmate_ai.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE workouts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL, exercise TEXT NOT NULL, reps INTEGER NOT NULL,
            weight REAL NOT NULL, media_title TEXT,
            media_minutes INTEGER NOT NULL DEFAULT 0,
            duration_minutes INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
    return _db!;
  }

  Future<int> addWorkout(Workout workout) async =>
      (await database).insert('workouts', workout.toMap());

  Future<List<Workout>> getWorkouts() async {
    final rows = await (await database).query('workouts', orderBy: 'date DESC, id DESC');
    return rows.map(Workout.fromMap).toList();
  }

  Future<int> importCloudWorkouts(List<Map<String, dynamic>> rows) async {
    final db = await database;
    final existing = await db.query('workouts');
    final keys = existing.map(_workoutKey).toSet();
    var added = 0;
    for (final row in rows) {
      final normalized = <String, Object?>{
        'date': DateTime.parse(row['date'] as String).toIso8601String(),
        'exercise': row['exercise'] as String,
        'reps': (row['reps'] as num).toInt(),
        'weight': (row['weight'] as num).toDouble(),
        'media_title': row['media_title'] as String?,
        'media_minutes': (row['media_minutes'] as num?)?.toInt() ?? 0,
        'duration_minutes': (row['duration_minutes'] as num?)?.toInt() ?? 0,
      };
      final key = _workoutKey(normalized);
      if (keys.add(key)) {
        await db.insert('workouts', normalized);
        added++;
      }
    }
    return added;
  }

  String _workoutKey(Map<String, Object?> row) =>
      '${DateTime.parse(row['date'] as String).toUtc().toIso8601String()}|'
      '${row['exercise']}|${row['reps']}|${row['weight']}|'
      '${row['media_title']}|${row['media_minutes']}|${row['duration_minutes']}';

  Future<void> deleteWorkout(int id) async {
    await (await database).delete('workouts', where: 'id = ?', whereArgs: [id]);
  }
}
