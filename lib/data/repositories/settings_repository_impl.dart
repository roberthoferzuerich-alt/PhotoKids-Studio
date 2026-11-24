import 'package:photokids_studio/data/datasources/preferences_datasource.dart';
import 'package:photokids_studio/domain/repositories/i_settings_repository.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  final PreferencesDatasource _datasource;

  SettingsRepositoryImpl(this._datasource);

  @override
  Future<bool> isKidModeActive() => _datasource.isKidModeActive();

  @override
  Future<void> setKidMode(bool active) => _datasource.setKidMode(active);

  @override
  Future<bool> verifyParentPin(String pin) => _datasource.verifyParentPin(pin);

  @override
  Future<void> setParentPin(String pin) => _datasource.setParentPin(pin);

  @override
  Future<bool> isPinSet() => _datasource.isPinSet();

  @override
  Future<int> getSlideshowSpeedSeconds() => _datasource.getSlideshowSpeedSeconds();

  @override
  Future<void> setSlideshowSpeedSeconds(int seconds) => _datasource.setSlideshowSpeedSeconds(seconds);

  @override
  Future<String> getThemeMode() => _datasource.getThemeMode();

  @override
  Future<void> setThemeMode(String mode) => _datasource.setThemeMode(mode);

  @override
  Future<int> getGridColumns() => _datasource.getGridColumns();

  @override
  Future<void> setGridColumns(int columns) => _datasource.setGridColumns(columns);
}
