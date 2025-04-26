import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../modes/app_mode.dart';
import '../../utils/settings/settings_repository.dart';

part 'app_mode_state.dart';

class AppModeCubit extends Cubit<AppMode> {
  final SettingsRepository settingsRepo;

  AppModeCubit({required this.settingsRepo})
      : super(settingsRepo.getAppMode());

  Future<void> switchMode(AppMode newMode) async {
    if (state == newMode) return;
    emit(newMode);
    await settingsRepo.setAppMode(newMode);

    // Можно добавить дополнительные действия при смене режима
    // Например, очистка кэша или обновление данных
  }


}