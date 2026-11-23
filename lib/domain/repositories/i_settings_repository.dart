abstract class ISettingsRepository {
  Future<bool> isKidModeActive();
  Future<void> setKidMode(bool active);
  Future<bool> verifyParentPin(String pin);
  Future<void> setParentPin(String pin);
  Future<bool> isPinSet();
  Future<int> getSlideshowSpeedSeconds();
  Future<void> setSlideshowSpeedSeconds(int seconds);
  Future<String> getThemeMode();
  Future<void> setThemeMode(String mode);
  Future<int> getGridColumns();
  Future<void> setGridColumns(int columns);
}
