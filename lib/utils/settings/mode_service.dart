import 'package:flutter/material.dart';

import '../../modes/app_mode.dart';
import 'settings_repository_interface.dart';

class ModeService extends ChangeNotifier {
  AppMode _currentMode;
  final SettingsRepositoryInterface _settingsRepo;

  AppMode get currentMode => _currentMode;

  ModeService({
    required SettingsRepositoryInterface settingsRepo,
    AppMode? initialMode,
  }) :
        _settingsRepo = settingsRepo,
        _currentMode = initialMode ?? settingsRepo.getAppMode();

  Future<void> setMode(AppMode mode) async {
    if (_currentMode == mode) return;

    _currentMode = mode;
    notifyListeners();

    await _settingsRepo.setAppMode(mode);
  }
}