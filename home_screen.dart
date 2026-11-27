import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/workout.dart';
import '../services/database_service.dart';
import '../services/supabase_service.dart';
import 'account_screen.dart';
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
  bool syncing = false;
  String? syncMessage;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await DatabaseService.instance.getWorkouts();
      if (!mounted) return;
      setState(() { workouts = data; loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { workouts = []; loading = false; });
    }
  }

  double get volume => workouts.fold(0, (s, w) => s + w.reps * w.weight);
  double get best => workouts.isEmpty ? 0 : workouts.map((w) => w.weight).reduce((a,b) => a > b ? a : b);

  List<FlSpot> get spots {
    final sorted = [...workouts]..sort((a,b) => a.date.compareTo(b.date));
    final map = <String,double>{};
    for (final w in sorted) {
      final k = '${w.date.year}-${w.date.month}-${w.date.day}';
      map[k] = (map[k] ?? 0) + w.reps*w.weight;
    }
    final values = map.values.toList();
    return values.isEmpty ? const [FlSpot(0,0)] :
      List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i]));
  }

  Future<void> _openWorkout() async {
    await Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, animation, secondary) => const WorkoutScreen(),
      transitionsBuilder: (_, animation, secondary, child) =>
        FadeTransition(opacity: animation, child: SlideTransition(
          position: Tween(begin: const Offset(0, .04), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child)),
      transitionDuration: const Duration(milliseconds: 320),
    ));
    _load();
  }


  Future<void> _sync() async {
    final supabase = SupabaseService.instance;
    if (!supabase.configured) {
      setState(() => syncMessage = AppState.instance.t(
        'لسه محتاج تضيف بيانات مشروع Supabase وتشغّل التطبيق بالمفاتيح.',
        'Add your Supabase project settings and launch with the required keys first.',
      ));
      return;
    }
    if (!supabase.isSignedIn) {
      final signedIn = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => const AccountScreen()));
      if (signedIn != true || !mounted) return;
    }
    setState(() { syncing = true; syncMessage = null; });
    try {
      final service = SupabaseService.instance;
      final uploaded = await service.syncWorkouts(workouts);
      final cloudRows = await service.fetchCloudWorkouts();
      final imported = await DatabaseService.instance.importCloudWorkouts(cloudRows);
      final refreshed = await DatabaseService.instance.getWorkouts();
      if (!mounted) return;
      setState(() {
        workouts = refreshed;
        syncing = false;
        syncMessage = AppState.instance.t(
          'المزامنة تمت: رفع $uploaded سجل، واسترجاع $imported سجل جديد.',
          'Sync complete: uploaded $uploaded records and restored $imported new records.',
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { syncing = false; syncMessage = e.toString().replaceFirst('Exception: ',''); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitMate AI 💪'),
        actions: [
          IconButton(
            tooltip: app.t('تغيير اللغة', 'Change language'),
            onPressed: app.toggleLanguage,
            icon: const Icon(Icons.translate),
          ),
          IconButton(
            tooltip: app.t('الحساب', 'Account'),
            onPressed: () async {
              if (SupabaseService.instance.configured && SupabaseService.instance.isSignedIn) {
                await SupabaseService.instance.signOut();
                if (mounted) setState(() => syncMessage = app.t('تم تسجيل الخروج.', 'Signed out.'));
              } else {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen()));
                if (mounted) setState(() {});
              }
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
          IconButton(
            tooltip: app.t('مزامنة أونلاين', 'Sync online'),
            onPressed: syncing ? null : _sync,
            icon: syncing
              ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2))
              : const Icon(Icons.cloud_sync_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openWorkout,
        icon: const Icon(Icons.add),
        label: Text(app.t('سجّل تمرين', 'Log workout')),
      ),
      body: loading ? const Center(child:CircularProgressIndicator()) :
        RefreshIndicator(
          onRefresh: _load,
          child: LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth > 650;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16,12,16,100),
                  children: [
                    AnimatedOpacity(
                      opacity: 1, duration: const Duration(milliseconds:500),
                      child: Text(app.t('يلا نتمرّن! 💪', 'Ready to train? 💪'),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.bold)),
                    ),
                    const SizedBox(height:16),
                    if (wide) Row(children: [
                      Expanded(child:_stat(app.t('المجموعات','Sets'), '${workouts.length}', Icons.fitness_center)),
                      const SizedBox(width:12),
                      Expanded(child:_stat(app.t('أعلى وزن','Best weight'), '${best.toStringAsFixed(1)} kg', Icons.trending_up)),
                      const SizedBox(width:12),
                      Expanded(child:_stat(app.t('حجم التدريب','Training volume'), volume.toStringAsFixed(0), Icons.bolt)),
                    ]) else Column(children: [
                      Row(children: [
                        Expanded(child:_stat(app.t('المجموعات','Sets'), '${workouts.length}', Icons.fitness_center)),
                        const SizedBox(width:10),
                        Expanded(child:_stat(app.t('أعلى وزن','Best weight'), '${best.toStringAsFixed(1)} kg', Icons.trending_up)),
                      ]),
                      const SizedBox(height:10),
                      _stat(app.t('حجم التدريب الكلي','Total training volume'), '${volume.toStringAsFixed(0)} kg × reps', Icons.bolt),
                    ]),
                    const SizedBox(height:14),
                    if (syncMessage != null) Padding(
                      padding: const EdgeInsets.only(bottom:12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds:250),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.teal.withOpacity(.10),borderRadius:BorderRadius.circular(12)),
                        child: Text(syncMessage!),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                          Text(app.t('تطور حجم التدريب','Training progress'),
                            style: const TextStyle(fontSize:17,fontWeight:FontWeight.bold)),
                          const SizedBox(height:18),
                          SizedBox(height:190,child:LineChart(LineChartData(
                            gridData: const FlGridData(show:true),
                            titlesData: const FlTitlesData(
                              topTitles: AxisTitles(sideTitles:SideTitles(showTitles:false)),
                              rightTitles: AxisTitles(sideTitles:SideTitles(showTitles:false)),
                            ),
                            borderData:FlBorderData(show:false),
                            lineBarsData:[LineChartBarData(
                              spots:spots,isCurved:true,barWidth:3,
                              dotData:const FlDotData(show:true),
                              belowBarData:BarAreaData(show:true),
                            )],
                          ))),
                        ]),
                      ),
                    ),
                    const SizedBox(height:14),
                    Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(
                      crossAxisAlignment:CrossAxisAlignment.start,children:[
                        Text(app.t('مساعد FitMate','FitMate Coach'),
                          style:const TextStyle(fontWeight:FontWeight.bold,fontSize:17)),
                        const SizedBox(height:8),
                        Text(InsightsService.summary(workouts, app.isArabic)),
                      ]))),
                    const SizedBox(height:18),
                    Text(app.t('آخر المجموعات','Recent sets'),
                      style:const TextStyle(fontWeight:FontWeight.bold,fontSize:18)),
                    const SizedBox(height:8),
                    if(workouts.isEmpty)
                      Card(child:Padding(padding:const EdgeInsets.all(18),
                        child:Text(app.t('لسه مفيش تمارين مسجلة. دوس على «سجّل تمرين» وابدأ.','No workouts yet. Tap “Log workout” to get started.'))))
                    else ...workouts.take(8).map((w)=>Padding(
                      padding:const EdgeInsets.only(bottom:8),
                      child: TweenAnimationBuilder<double>(
                        tween:Tween(begin:0,end:1),duration:const Duration(milliseconds:350),
                        builder:(context,v,child)=>Transform.translate(
                          offset:Offset(0,12*(1-v)),child:Opacity(opacity:v,child:child)),
                        child:Card(child:ListTile(
                          leading:const CircleAvatar(child:Icon(Icons.fitness_center)),
                          title:Text(w.exercise),
                          subtitle:Text('${w.reps} ${app.t('عدة','reps')} × ${w.weight} kg • ${w.date.day}/${w.date.month}/${w.date.year}'),
                          trailing:w.mediaTitle==null?null:const Icon(Icons.headphones),
                        )),
                      ),
                    )),
                  ],
                ),
              ),
            );
          }),
        ),
    );
  }

  Widget _stat(String title,String value,IconData icon)=>Card(
    child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[
      Icon(icon,size:27),const SizedBox(width:10),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(title,style:const TextStyle(color:Colors.black54)),
        const SizedBox(height:4),
        AnimatedSwitcher(duration:const Duration(milliseconds:250),
          child:Text(value,key:ValueKey(value),style:const TextStyle(fontWeight:FontWeight.bold,fontSize:18))),
      ])),
    ])),
  );
}
