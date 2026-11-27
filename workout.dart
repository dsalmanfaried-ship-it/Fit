class Workout {
  final int? id;
  final DateTime date;
  final String exercise;
  final int reps;
  final double weight;
  final String? mediaTitle;
  final int mediaMinutes;
  final int durationMinutes;

  const Workout({
    this.id,
    required this.date,
    required this.exercise,
    required this.reps,
    required this.weight,
    this.mediaTitle,
    this.mediaMinutes = 0,
    this.durationMinutes = 0,
  });

  Map<String, Object?> toMap() => {
    'id': id, 'date': date.toIso8601String(), 'exercise': exercise,
    'reps': reps, 'weight': weight, 'media_title': mediaTitle,
    'media_minutes': mediaMinutes, 'duration_minutes': durationMinutes,
  };

  factory Workout.fromMap(Map<String, Object?> map) => Workout(
    id: map['id'] as int?,
    date: DateTime.parse(map['date'] as String),
    exercise: map['exercise'] as String,
    reps: map['reps'] as int,
    weight: (map['weight'] as num).toDouble(),
    mediaTitle: map['media_title'] as String?,
    mediaMinutes: map['media_minutes'] as int? ?? 0,
    durationMinutes: map['duration_minutes'] as int? ?? 0,
  );
}
