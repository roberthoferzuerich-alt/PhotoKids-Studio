import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:denis_phote_world/core/di/app_providers.dart';
import 'package:denis_phote_world/domain/repositories/i_settings_repository.dart';

class SettingsState {
  final bool isKidMode;
  final bool isParentPinSet;
  final int slideshowSpeed;
  final String themeMode;
  final int gridColumns;

  const SettingsState({
    this.isKidMode = true,
    this.isParentPinSet = false,
    this.slideshowSpeed = 3,
    this.themeMode = 'system',
    this.gridColumns = 3,
  });

  SettingsState copyWith({
    bool? isKidMode,
    bool? isParentPinSet,
    int? slideshowSpeed,
    String? themeMode,
    int? gridColumns,
  }) {
    return SettingsState(
      isKidMode: isKidMode ?? this.isKidMode,
      isParentPinSet: isParentPinSet ?? this.isParentPinSet,
      slideshowSpeed: slideshowSpeed ?? this.slideshowSpeed,
      themeMode: themeMode ?? this.themeMode,
      gridColumns: gridColumns ?? this.gridColumns,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final ISettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const SettingsState()) {
    _init();
  }

  Future<void> _init() async {
    final kidMode = await _repository.isKidModeActive();
    final pinSet = await _repository.isPinSet();
    final speed = await _repository.getSlideshowSpeedSeconds();
    final theme = await _repository.getThemeMode();
    final cols = await _repository.getGridColumns();

    state = SettingsState(
      isKidMode: kidMode,
      isParentPinSet: pinSet,
      slideshowSpeed: speed,
      themeMode: theme,
      gridColumns: cols,
    );
  }

  Future<bool> verifyAndToggleKidMode(String pin) async {
    final valid = await _repository.verifyParentPin(pin);
    if (valid) {
      final newMode = !state.isKidMode;
      await _repository.setKidMode(newMode);
      state = state.copyWith(isKidMode: newMode);
      return true;
    }
    return false;
  }

  Future<void> setKidModeDirect(bool active) async {
    await _repository.setKidMode(active);
    state = state.copyWith(isKidMode: active);
  }

  Future<void> setParentPin(String pin) async {
    await _repository.setParentPin(pin);
    state = state.copyWith(isParentPinSet: true);
  }

  Future<void> setSlideshowSpeed(int seconds) async {
    await _repository.setSlideshowSpeedSeconds(seconds);
    state = state.copyWith(slideshowSpeed: seconds);
  }

  Future<void> setThemeMode(String mode) async {
    await _repository.setThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }
}

final settingsControllerProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});
