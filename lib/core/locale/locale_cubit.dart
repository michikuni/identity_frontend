import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  static const _key = 'app_locale';

  LocaleCubit() : super(const Locale('vi'));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'vi';
    emit(Locale(code));
  }

  Future<void> toggle() async {
    final next = state.languageCode == 'vi' ? const Locale('en') : const Locale('vi');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, next.languageCode);
    emit(next);
  }
}
