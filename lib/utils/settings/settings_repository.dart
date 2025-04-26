import 'package:shared_preferences/shared_preferences.dart';

import '../../modes/app_mode.dart';
import 'settings_repository_interface.dart';

class SettingsRepository implements SettingsRepositoryInterface{
  final SharedPreferences sharedPreferences;
  static const _isDarkThemeSelectedKey = 'dark_theme_selected';
  static const _appModeKey = 'selected_app_mode';

  SettingsRepository({required this.sharedPreferences});

  @override
  bool isDarkThemeSelected() {
    final selected = sharedPreferences.getBool(_isDarkThemeSelectedKey);
    return selected ?? false;
  }

  @override
  Future<void> setDarkThemeSelected(bool isSelected) async {
    await sharedPreferences.setBool(_isDarkThemeSelectedKey, isSelected);
  }

  @override
  AppMode getAppMode() {
    final savedIndex = sharedPreferences.getInt(_appModeKey);
    return savedIndex != null
        ? AppMode.values[savedIndex]
        : AppMode.writerMode;
  }

  @override
  Future<void> setAppMode(AppMode mode) async {
    await sharedPreferences.setInt(_appModeKey, mode.index);
  }
}