import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout.dart';

/// Optional REST sync. Set --dart-define=FITMATE_API_URL=https://your-api.example.com
/// and implement POST /workouts and GET /workouts for the signed-in user on your server.
class OnlineService {
  static const String apiUrl = String.fromEnvironment('FITMATE_API_URL');
  static bool get isConfigured => apiUrl.isNotEmpty;

  Future<bool> syncWorkouts(List<Workout> workouts) async {
    if (!isConfigured) return false;
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/workouts/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'workouts': workouts.map((w) => w.toMap()..remove('id')).toList()}),
      ).timeout(const Duration(seconds: 12));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchExerciseCatalog() async {
    if (!isConfigured) return null;
    try {
      final response = await http.get(Uri.parse('$apiUrl/exercises'))
        .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body);
      if (data is! List) return null;
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return null;
    }
  }
}
