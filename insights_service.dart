import '../models/workout.dart';

class InsightsService {
  static String summary(List<Workout> workouts) {
    if (workouts.isEmpty) {
      return 'ابدأ بتسجيل أول تمرين، وبعدها هتظهر هنا ملاحظات عن تقدمك.';
    }
    final total = workouts.length;
    final volume = workouts.fold<double>(0, (sum, w) => sum + w.reps * w.weight);
    final best = workouts.map((w) => w.weight).reduce((a, b) => a > b ? a : b);
    final uniqueDays = workouts.map((w) =>
      DateTime(w.date.year, w.date.month, w.date.day).toIso8601String()).toSet().length;
    return 'سجلت $total مجموعة على $uniqueDays يوم تدريب. '
        'إجمالي حجم التدريب ${volume.toStringAsFixed(0)} كجم-عدة، '
        'وأعلى وزن مسجل ${best.toStringAsFixed(1)} كجم. استمر بنفس الانتظام وزوّد الحمل تدريجياً وبشكل آمن.';
  }
}
