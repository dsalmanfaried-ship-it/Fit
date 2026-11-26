import '../models/workout.dart';

class InsightsService {
  static String summary(List<Workout> workouts, bool ar) {
    if (workouts.isEmpty) {
      return ar
        ? 'ابدأ سجّل أول مجموعة، وأنا هتابع معاك تقدمك خطوة بخطوة.'
        : 'Log your first set and I’ll help you track your progress.';
    }
    final volume = workouts.fold<double>(0,(s,w)=>s+w.reps*w.weight);
    final best = workouts.map((w)=>w.weight).reduce((a,b)=>a>b?a:b);
    final days = workouts.map((w)=>DateTime(w.date.year,w.date.month,w.date.day).toIso8601String()).toSet().length;
    return ar
      ? 'عاش! سجلت ${workouts.length} مجموعة في $days يوم تدريب. حجم تدريبك ${volume.toStringAsFixed(0)} كجم-عدة، وأعلى وزن ${best.toStringAsFixed(1)} كجم. زوّد الحمل بالتدريج وخلي الفورمة مظبوطة.'
      : 'Nice work! You logged ${workouts.length} sets across $days training days. Total volume: ${volume.toStringAsFixed(0)} kg-reps; best recorded weight: ${best.toStringAsFixed(1)} kg. Progress gradually and keep good form.';
  }
}
