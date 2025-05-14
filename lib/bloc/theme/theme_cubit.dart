import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../utils/settings/settings_repository_interface.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({required this.settingsRepository}) : super(const ThemeState(Brightness.light)) {_checkSelectedTheme();}
  final SettingsRepositoryInterface settingsRepository;
  Future<void> setTheme(Brightness brightness) async{
    emit(ThemeState(brightness));
    await settingsRepository.setDarkThemeSelected(brightness == Brightness.dark);
  }
  void _checkSelectedTheme() {
    final brightness = settingsRepository.isDarkThemeSelected() ? Brightness.dark : Brightness.light;
    emit(ThemeState(brightness));
  }
}
