import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/supabase_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState()=>_AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final email=TextEditingController();
  final password=TextEditingController();
  bool busy=false;
  bool createAccount=false;
  String? message;

  Future<void> _submit() async {
    setState((){busy=true;message=null;});
    try {
      if(createAccount) {
        await SupabaseService.instance.signUp(email.text,password.text);
        message=AppState.instance.t('لو تأكيد الإيميل مفعّل، افتح رسالة التأكيد وبعدها سجّل دخول.','If email confirmation is enabled, confirm your email then sign in.');
      } else {
        await SupabaseService.instance.signIn(email.text,password.text);
        if(mounted) Navigator.pop(context,true);
      }
    } catch(e) {
      message=e.toString().replaceFirst('Exception: ','');
    } finally {
      if(mounted)setState(()=>busy=false);
    }
  }

  @override
  void dispose(){email.dispose();password.dispose();super.dispose();}

  @override
  Widget build(BuildContext context) {
    final t=AppState.instance.t;
    return Scaffold(
      appBar:AppBar(title:Text(t('حساب FitMate','FitMate account'))),
      body:Center(child:ConstrainedBox(
        constraints:const BoxConstraints(maxWidth:480),
        child:ListView(padding:const EdgeInsets.all(20),children:[
          const Icon(Icons.cloud_done_outlined,size:64),
          const SizedBox(height:16),
          Text(t('سجّل دخولك عشان تحفظ تقدمك أونلاين','Sign in to back up your progress online'),
            textAlign:TextAlign.center,style:Theme.of(context).textTheme.titleLarge),
          const SizedBox(height:24),
          TextField(controller:email,keyboardType:TextInputType.emailAddress,
            decoration:InputDecoration(labelText:t('البريد الإلكتروني','Email'))),
          const SizedBox(height:12),
          TextField(controller:password,obscureText:true,
            decoration:InputDecoration(labelText:t('كلمة المرور','Password'))),
          const SizedBox(height:16),
          FilledButton(onPressed:busy?null:_submit,
            child:busy?const CircularProgressIndicator():Text(createAccount?t('إنشاء حساب','Create account'):t('تسجيل الدخول','Sign in'))),
          TextButton(onPressed:busy?null:()=>setState(()=>createAccount=!createAccount),
            child:Text(createAccount?t('عندي حساب بالفعل','I already have an account'):t('إنشاء حساب جديد','Create a new account'))),
          if(message!=null) Padding(padding:const EdgeInsets.only(top:12),child:Text(message!,textAlign:TextAlign.center)),
        ]),
      )),
    );
  }
}
