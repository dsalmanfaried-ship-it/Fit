import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();
  static const _storageKey = 'fitmate_workouts_v1';
  static const _nextIdKey = 'fitmate_next_workout_id_v1';

  Future<List<Map<String, dynamic>>> _read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _write(List<Map<String, dynamic>> rows) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(rows));
  }

  Future<int> addWorkout(Workout workout) async {
    final prefs = await SharedPreferences.getInstance();
    final rows = await _read();
    final id = prefs.getInt(_nextIdKey) ?? 1;
    rows.add(workout.toMap()..['id'] = id);
    await _write(rows);
    await prefs.setInt(_nextIdKey, id + 1);
    return id;
  }

  Future<List<Workout>> getWorkouts() async {
    final rows = await _read();
    rows.sort((a, b) => DateTime.parse(b['date'] as String)
        .compareTo(DateTime.parse(a['date'] as String)));
    return rows.map((row) => Workout.fromMap(row)).toList();
  }

  Future<int> importCloudWorkouts(List<Map<String, dynamic>> cloudRows) async {
    final rows = await _read();
    final keys = rows.map(_workoutKey).toSet();
    final prefs = await SharedPreferences.getInstance();
    var nextId = prefs.getInt(_nextIdKey) ?? 1;
    var added = 0;
    for (final cloud in cloudRows) {
      final row = <String, dynamic>{
        'id': nextId,
        'date': DateTime.parse(cloud['date'] as String).toIso8601String(),
        'exercise': cloud['exercise'] as String,
        'reps': (cloud['reps'] as num).toInt(),
        'weight': (cloud['weight'] as num).toDouble(),
        'media_title': cloud['media_title'] as String?,
        'media_minutes': (cloud['media_minutes'] as num?)?.toInt() ?? 0,
        'duration_minutes': (cloud['duration_minutes'] as num?)?.toInt() ?? 0,
      };
      if (keys.add(_workoutKey(row))) {
        rows.add(row);
        nextId++;
        added++;
      }
    }
    await _write(rows);
    await prefs.setInt(_nextIdKey, nextId);
    return added;
  }

  String _workoutKey(Map<String, dynamic> row) =>
      '${DateTime.parse(row['date'] as String).toUtc().toIso8601String()}|'
      '${row['exercise']}|${row['reps']}|${row['weight']}|'
      '${row['media_title']}|${row['media_minutes']}|${row['duration_minutes']}';

  Future<void> deleteWorkout(int id) async {
    final rows = await _read();
    rows.removeWhere((row) => row['id'] == id);
    await _write(rows);
  }
}
