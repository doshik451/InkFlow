import 'package:shared_preferences/shared_preferences.dart';

import 'settings_repository_interface.dart';

class SettingsRepository implements SettingsRepositoryInterface{
  final SharedPreferences sharedPreferences;
  static const _isDarkThemeSelectedKey = 'dark_theme_selected';
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

}