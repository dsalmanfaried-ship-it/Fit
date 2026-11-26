import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/database_service.dart';
import '../services/insights_service.dart';
import 'workout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Workout> workouts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseService.instance.getWorkouts();
    if (!mounted) return;
    setState(() { workouts = data; loading = false; });
  }

  double get totalVolume =>
      workouts.fold(0, (sum, w) => sum + w.reps * w.weight);
  double get bestWeight => workouts.isEmpty
      ? 0 : workouts.map((w) => w.weight).reduce((a, b) => a > b ? a : b);

  List<FlSpot> get chartSpots {
    final sorted = [...workouts]..sort((a, b) => a.date.compareTo(b.date));
    final byDay = <String, double>{};
    for (final w in sorted) {
      final key = '${w.date.year}-${w.date.month}-${w.date.day}';
      byDay[key] = (byDay[key] ?? 0) + w.reps * w.weight;
    }
    final values = byDay.values.toList();
    if (values.isEmpty) return const [FlSpot(0, 0)];
    return List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i]));
  }

  Future<void> _openWorkout() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutScreen()));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FitMate AI 💪')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openWorkout,
        icon: const Icon(Icons.add),
        label: const Text('سجّل تمرين'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                children: [
                  Text('أهلاً بيك! جاهز لتمرين جديد؟',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _statCard('المجموعات', '${workouts.length}', Icons.fitness_center)),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard('أعلى وزن', '${bestWeight.toStringAsFixed(1)} kg', Icons.trending_up)),
                  ]),
                  const SizedBox(height: 10),
                  _statCard('حجم التدريب الكلي', '${totalVolume.toStringAsFixed(0)} kg × reps', Icons.bolt),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('تطور حجم التدريب', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 18),
                        SizedBox(height: 190, child: LineChart(LineChartData(
                          gridData: const FlGridData(show: true),
                          titlesData: const FlTitlesData(
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [LineChartBarData(
                            spots: chartSpots,
                            isCurved: true,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          )],
                        ))),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('مساعد FitMate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 8),
                      Text(InsightsService.summary(workouts)),
                    ]),
                  )),
                  const SizedBox(height: 16),
                  const Text('آخر المجموعات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  if (workouts.isEmpty)
                    const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('لسه مفيش تمارين مسجلة. اضغط «سجّل تمرين» للبدء.')))
                  else
                    ...workouts.take(8).map((w) => Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
                        title: Text(w.exercise),
                        subtitle: Text('${w.reps} عدة × ${w.weight} كجم • ${w.date.day}/${w.date.month}/${w.date.year}'),
                        trailing: w.mediaTitle == null || w.mediaTitle!.isEmpty
                          ? null : const Icon(Icons.headphones),
                      ),
                    )),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Icon(icon, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ])),
      ]),
    ),
  );
}
