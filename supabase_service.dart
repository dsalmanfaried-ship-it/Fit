import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  bool get configured {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  SupabaseClient get client => Supabase.instance.client;
  User? get currentUser => configured ? client.auth.currentUser : null;
  bool get isSignedIn => currentUser != null;

  Future<void> signUp(String email, String password) async {
    await client.auth.signUp(email: email.trim(), password: password);
  }

  Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(email: email.trim(), password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<int> syncWorkouts(List<Workout> workouts) async {
    final user = currentUser;
    if (user == null) throw Exception('سجّل دخولك الأول.');
    final rows = workouts.map((w) => {
      'user_id': user.id,
      'client_key': '${w.date.toUtc().microsecondsSinceEpoch}_${w.exercise}_${w.reps}_${w.weight}',
      'date': w.date.toUtc().toIso8601String(),
      'exercise': w.exercise,
      'reps': w.reps,
      'weight': w.weight,
      'media_title': w.mediaTitle,
      'media_minutes': w.mediaMinutes,
      'duration_minutes': w.durationMinutes,
    }).toList();

    if (rows.isEmpty) return 0;
    // Upsert prevents duplicate rows when the same local history is synced again.
    await client.from('workouts').upsert(
      rows,
      onConflict: 'user_id,client_key',
      ignoreDuplicates: true,
    );
    return rows.length;
  }

  Future<List<Map<String, dynamic>>> fetchCloudWorkouts() async {
    final user = currentUser;
    if (user == null) throw Exception('سجّل دخولك الأول.');
    final data = await client.from('workouts')
      .select('date, exercise, reps, weight, media_title, media_minutes, duration_minutes')
      .eq('user_id', user.id)
      .order('date', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }
}
