import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  static const String _localeKey = 'selected_locale';

  LocaleCubit() : super(LocaleState(_getInitialLocale()));

  static Locale _getInitialLocale() {
    final systemLocale = PlatformDispatcher.instance.locale;
    return systemLocale.languageCode == 'ru' ? const Locale('ru') : const Locale('en');
  }

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null) {
      emit(LocaleState(Locale(savedLocale)));
    }
  }

  Future<void> toggleLocale() async {
    final newLocale = state.locale.languageCode == 'ru' ? const Locale('en') : const Locale('ru');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, newLocale.languageCode);
    emit(LocaleState(newLocale));
  }
}
