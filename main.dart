import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_state.dart';
import 'screens/home_screen.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.load();
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
  runApp(const FitMateApp());
}

class FitMateApp extends StatelessWidget {
  const FitMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final ar = AppState.instance.isArabic;
        return MaterialApp(
          title: 'FitMate AI',
          debugShowCheckedModeBanner: false,
          locale: Locale(ar ? 'ar' : 'en'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9B78)),
            scaffoldBackgroundColor: const Color(0xFFF3F7F6),
            appBarTheme: const AppBarTheme(centerTitle: false),
            cardTheme: const CardThemeData(elevation: 1, margin: EdgeInsets.zero, color: Colors.white),
            inputDecorationTheme: const InputDecorationTheme(filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
          ),
          builder: (context, child) => Directionality(
            textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: KeyedSubtree(key: ValueKey(ar), child: child ?? const SizedBox.shrink()),
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
