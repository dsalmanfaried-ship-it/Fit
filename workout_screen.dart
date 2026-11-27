import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../app_state.dart';
import '../models/workout.dart';
import '../services/database_service.dart';
import '../services/voice_parser.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});
  @override
  State<WorkoutScreen> createState()=>_WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final exercise=TextEditingController(text:'Bench Press');
  final reps=TextEditingController(text:'10');
  final weight=TextEditingController(text:'20');
  final media=TextEditingController();
  final mediaMinutes=TextEditingController(text:'0');
  final duration=TextEditingController(text:'60');
  final speech=stt.SpeechToText();
  bool listening=false, speechAvailable=false;
  int rest=0;
  Timer? timer;

  @override
  void initState(){super.initState();_initSpeech();}
  Future<void> _initSpeech() async {
    speechAvailable=await speech.initialize();
    if(mounted)setState((){});
  }

  Future<void> _listen() async {
    final ar=AppState.instance.isArabic;
    if(!speechAvailable){_message(ar?'خدمة التعرف على الصوت مش متاحة على الجهاز.':'Speech recognition is unavailable on this device.');return;}
    if(listening){await speech.stop();setState(()=>listening=false);return;}
    setState(()=>listening=true);
    await speech.listen(
      localeId: ar?'ar_EG':'en_US',
      listenFor:const Duration(seconds:25),
      onResult:(result){
        if(result.finalResult){
          final parsed=VoiceParser.parse(result.recognizedWords);
          if(parsed!=null){reps.text=parsed.reps.toString();weight.text=parsed.weight.toString();}
          else {_message(ar?'مسمعتش العدات والوزن بوضوح. جرّب تقول: ١٢ عدة بوزن ٤٠ كيلو.':'Could not detect reps and weight. Try: 12 reps at 40 kg.');}
          setState(()=>listening=false);
        }
      },
    );
  }

  void _restTimer(){
    timer?.cancel();setState(()=>rest=90);
    timer=Timer.periodic(const Duration(seconds:1),(t){
      if(rest<=1){t.cancel();setState(()=>rest=0);}else{setState(()=>rest--);}
    });
  }

  Future<void> _save() async {
    final app=AppState.instance;
    final r=int.tryParse(reps.text.trim());
    final w=double.tryParse(weight.text.trim().replaceAll(',','.'));
    if(exercise.text.trim().isEmpty||r==null||r<1||w==null||w<0){
      _message(app.t('راجع اسم التمرين والعدات والوزن.','Check exercise, reps and weight.'));return;
    }
    await DatabaseService.instance.addWorkout(Workout(
      date:DateTime.now(),exercise:exercise.text.trim(),reps:r,weight:w,
      mediaTitle:media.text.trim().isEmpty?null:media.text.trim(),
      mediaMinutes:(int.tryParse(mediaMinutes.text)??0).clamp(0,100000).toInt(),
      durationMinutes:(int.tryParse(duration.text)??0).clamp(0,100000).toInt(),
    ));
    if(mounted)Navigator.pop(context);
  }

  void _message(String s)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));

  @override
  void dispose(){
    timer?.cancel();exercise.dispose();reps.dispose();weight.dispose();
    media.dispose();mediaMinutes.dispose();duration.dispose();speech.stop();super.dispose();
  }

  @override
  Widget build(BuildContext context){
    final app=AppState.instance;
    return Scaffold(
      appBar:AppBar(title:Text(app.t('تسجيل مجموعة','Log a set'))),
      body:Center(child:ConstrainedBox(
        constraints:const BoxConstraints(maxWidth:650),
        child:ListView(padding:const EdgeInsets.all(16),children:[
          _field(exercise,app.t('اسم التمرين','Exercise name')),
          const SizedBox(height:12),
          LayoutBuilder(builder:(context,c)=>c.maxWidth<420
            ?Column(children:[_field(reps,app.t('العدات','Reps'),number:true),const SizedBox(height:10),_field(weight,app.t('الوزن (كجم)','Weight (kg)'),number:true)])
            :Row(children:[Expanded(child:_field(reps,app.t('العدات','Reps'),number:true)),const SizedBox(width:10),Expanded(child:_field(weight,app.t('الوزن (كجم)','Weight (kg)'),number:true))])),
          const SizedBox(height:12),
          AnimatedScale(scale:listening?1.02:1,duration:const Duration(milliseconds:180),
            child:FilledButton.icon(
              onPressed:_listen,
              icon:Icon(listening?Icons.graphic_eq:Icons.mic_none),
              label:Text(listening?app.t('بسمعك... اضغط للإيقاف','Listening... tap to stop'):app.t('سجّل العدات والوزن بالصوت','Speak reps and weight')),
            )),
          Padding(padding:const EdgeInsets.only(top:8),child:Text(
            app.t('مثال: «عملت ١٢ عدة بوزن ٤٠ كيلو»','Example: “12 reps at 40 kilos”'),
            style:const TextStyle(color:Colors.black54))),
          const Divider(height:32),
          Text(app.t('المزيكا أو البودكاست','Music or podcast'),style:const TextStyle(fontWeight:FontWeight.bold)),
          const SizedBox(height:10),
          _field(media,app.t('اسم اللي بتسمعه','What are you listening to?')),
          const SizedBox(height:10),
          LayoutBuilder(builder:(context,c)=>c.maxWidth<420
            ?Column(children:[_field(mediaMinutes,app.t('مدة الاستماع بالدقايق','Listening minutes'),number:true),const SizedBox(height:10),_field(duration,app.t('مدة التمرين بالدقايق','Workout minutes'),number:true)])
            :Row(children:[Expanded(child:_field(mediaMinutes,app.t('مدة الاستماع بالدقايق','Listening minutes'),number:true)),const SizedBox(width:10),Expanded(child:_field(duration,app.t('مدة التمرين بالدقايق','Workout minutes'),number:true))])),
          const SizedBox(height:16),
          AnimatedContainer(duration:const Duration(milliseconds:250),
            padding:const EdgeInsets.all(14),
            decoration:BoxDecoration(color:Colors.teal.withOpacity(.08),borderRadius:BorderRadius.circular(16)),
            child:Row(children:[
              Expanded(child:Text(app.t('مؤقت الراحة','Rest timer'),style:const TextStyle(fontWeight:FontWeight.bold))),
              Text(rest==0?'01:30':'${(rest~/60).toString().padLeft(2,'0')}:${(rest%60).toString().padLeft(2,'0')}',
                style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
              const SizedBox(width:10),
              FilledButton.tonal(onPressed:_restTimer,child:Text(app.t('ابدأ','Start'))),
            ])),
          const SizedBox(height:20),
          FilledButton(
            onPressed:_save,
            style:FilledButton.styleFrom(padding:const EdgeInsets.all(16)),
            child:Text(app.t('حفظ المجموعة','Save set')),
          ),
        ]),
      )),
    );
  }

  Widget _field(TextEditingController controller,String label,{bool number=false})=>TextField(
    controller:controller,
    keyboardType:number?const TextInputType.numberWithOptions(decimal:true):TextInputType.text,
    decoration:InputDecoration(labelText:label,border:const OutlineInputBorder()),
  );
}
