abstract interface class SettingsRepositoryInterface {
  bool isDarkThemeSelected();
  Future<void> setDarkThemeSelected(bool isSelected);
}