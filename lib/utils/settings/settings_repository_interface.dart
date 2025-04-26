import '../../modes/app_mode.dart';

abstract interface class SettingsRepositoryInterface {
  bool isDarkThemeSelected();
  Future<void> setDarkThemeSelected(bool isSelected);
  AppMode getAppMode();
  Future<void> setAppMode(AppMode mode);
}