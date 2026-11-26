import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/workout.dart';
import '../services/database_service.dart';
import '../services/voice_parser.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});
  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final exercise = TextEditingController(text: 'Bench Press');
  final reps = TextEditingController(text: '10');
  final weight = TextEditingController(text: '20');
  final media = TextEditingController();
  final mediaMinutes = TextEditingController(text: '0');
  final duration = TextEditingController(text: '60');
  final speech = stt.SpeechToText();
  bool listening = false;
  bool speechAvailable = false;
  int restSeconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    speechAvailable = await speech.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _listen() async {
    if (!speechAvailable) {
      _show('التعرف على الصوت غير متاح على الجهاز. راجع إعدادات الميكروفون.');
      return;
    }
    if (listening) {
      await speech.stop();
      setState(() => listening = false);
      return;
    }
    setState(() => listening = true);
    await speech.listen(
      localeId: 'ar_EG',
      listenFor: const Duration(seconds: 20),
      onResult: (result) {
        if (result.finalResult) {
          final parsed = VoiceParser.parse(result.recognizedWords);
          if (parsed != null) {
            reps.text = parsed.reps.toString();
            weight.text = parsed.weight.toString();
          }
          setState(() => listening = false);
        }
      },
    );
  }

  void _startRest() {
    timer?.cancel();
    setState(() => restSeconds = 90);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (restSeconds <= 1) {
        t.cancel();
        setState(() => restSeconds = 0);
      } else {
        setState(() => restSeconds--);
      }
    });
  }

  Future<void> _save() async {
    final r = int.tryParse(reps.text.trim());
    final w = double.tryParse(weight.text.trim().replaceAll(',', '.'));
    final mediaM = int.tryParse(mediaMinutes.text.trim()) ?? 0;
    final durationM = int.tryParse(duration.text.trim()) ?? 0;
    if (exercise.text.trim().isEmpty || r == null || r < 1 || w == null || w < 0) {
      _show('اكتب اسم التمرين وعدد العدات والوزن بشكل صحيح.');
      return;
    }
    await DatabaseService.instance.addWorkout(Workout(
      date: DateTime.now(),
      exercise: exercise.text.trim(),
      reps: r,
      weight: w,
      mediaTitle: media.text.trim().isEmpty ? null : media.text.trim(),
      mediaMinutes: mediaM < 0 ? 0 : mediaM,
      durationMinutes: durationM < 0 ? 0 : durationM,
    ));
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    timer?.cancel();
    exercise.dispose(); reps.dispose(); weight.dispose(); media.dispose();
    mediaMinutes.dispose(); duration.dispose();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل مجموعة')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: exercise, decoration: const InputDecoration(labelText: 'اسم التمرين', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: reps, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'العدات', border: OutlineInputBorder()))),
          const SizedBox(width: 10),
          Expanded(child: TextField(controller: weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'الوزن (كجم)', border: OutlineInputBorder()))),
        ]),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _listen,
          icon: Icon(listening ? Icons.mic : Icons.mic_none),
          label: Text(listening ? 'إيقاف الاستماع' : 'سجّل العدات والوزن بالصوت'),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text('مثال: «12 عدة وزن 40 كيلو» أو “12 reps 40 kg”.', style: TextStyle(color: Colors.black54)),
        ),
        const Divider(height: 32),
        const Text('الصوت أو المحتوى اللي بتسمعه', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(controller: media, decoration: const InputDecoration(labelText: 'اسم الأغنية أو البودكاست', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(controller: mediaMinutes, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مدة الاستماع بالدقائق', border: OutlineInputBorder()))),
          const SizedBox(width: 10),
          Expanded(child: TextField(controller: duration, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مدة التمرين بالدقائق', border: OutlineInputBorder()))),
        ]),
        const SizedBox(height: 18),
        Card(child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Expanded(child: Text('مؤقت الراحة')),
            Text(restSeconds == 0 ? '90 ثانية' : '${restSeconds}s', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(width: 10),
            FilledButton.tonal(onPressed: _startRest, child: const Text('ابدأ 90 ثانية')),
          ]),
        )),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
          child: const Text('حفظ المجموعة'),
        ),
      ]),
    );
  }
}
