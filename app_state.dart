import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();
  bool isArabic = true;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isArabic = prefs.getBool('isArabic') ?? true;
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    isArabic = !isArabic;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isArabic', isArabic);
    notifyListeners();
  }

  String t(String ar, String en) => isArabic ? ar : en;
}
