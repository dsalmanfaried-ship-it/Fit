import 'package:flutter/material.dart';
import 'app_state.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.load();
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
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D9B78),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF3F7F6),
            appBarTheme: const AppBarTheme(centerTitle: false),
            cardTheme: const CardThemeData(
              elevation: 1,
              margin: EdgeInsets.zero,
              color: Colors.white,
            ),
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
          builder: (context, child) => Directionality(
            textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: KeyedSubtree(
                key: ValueKey(ar),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
