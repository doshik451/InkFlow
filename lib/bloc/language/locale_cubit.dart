import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  static const String _localeKey = 'selected_locale';
  static const List<String> supportedLocales = ['en', 'ru', 'be'];

  LocaleCubit() : super(LocaleState(_getInitialLocale()));

  static Locale _getInitialLocale() {
    final prefs = SharedPreferences.getInstance();
    final savedLocale = prefs.then((p) => p.getString(_localeKey));

    if (savedLocale != null && supportedLocales.contains(savedLocale)) {
      return Locale(savedLocale as String);
    }

    final systemLocale = PlatformDispatcher.instance.locale;

    if (supportedLocales.contains(systemLocale.languageCode)) {
      return Locale(systemLocale.languageCode);
    }

    final shortCode = systemLocale.toString().split('_').first;
    if (supportedLocales.contains(shortCode)) {
      return Locale(shortCode);
    }

    return const Locale('en');
  }

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null && supportedLocales.contains(savedLocale)) {
      emit(LocaleState(Locale(savedLocale)));
    }
  }

  Future<void> toggleLocale() async {
    final currentIndex = supportedLocales.indexOf(state.locale.languageCode);
    final nextIndex = (currentIndex + 1) % supportedLocales.length;
    final newLocale = Locale(supportedLocales[nextIndex]);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, newLocale.languageCode);
    emit(LocaleState(newLocale));
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale.languageCode)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    emit(LocaleState(locale));
  }
}
