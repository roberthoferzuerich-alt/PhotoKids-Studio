import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photokids_studio/core/constants/app_constants.dart';

class PreferencesDatasource {
  static const String _keyKidMode = 'pref_kid_mode';
  static const String _keyParentPinHash = 'pref_parent_pin_hash';
  static const String _keySlideshowSpeed = 'pref_slideshow_speed';
  static const String _keyThemeMode = 'pref_theme_mode';
  static const String _keyGridColumns = 'pref_grid_columns';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<bool> isKidModeActive() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyKidMode) ?? true; // Default to kid mode on for safety
  }

  Future<void> setKidMode(bool active) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyKidMode, active);
  }

  Future<bool> isPinSet() async {
    final prefs = await _prefs;
    return prefs.getString(_keyParentPinHash) != null;
  }

  Future<bool> verifyParentPin(String pin) async {
    final prefs = await _prefs;
    final savedHash = prefs.getString(_keyParentPinHash);
    if (savedHash == null) {
      // Fallback to default PIN '1234' if none has been configured
      return pin == AppConstants.defaultParentPin;
    }
    return savedHash == _hashPin(pin);
  }

  Future<void> setParentPin(String pin) async {
    final prefs = await _prefs;
    await prefs.setString(_keyParentPinHash, _hashPin(pin));
  }

  Future<int> getSlideshowSpeedSeconds() async {
    final prefs = await _prefs;
    return prefs.getInt(_keySlideshowSpeed) ?? 3;
  }

  Future<void> setSlideshowSpeedSeconds(int seconds) async {
    final prefs = await _prefs;
    await prefs.setInt(_keySlideshowSpeed, seconds);
  }

  Future<String> getThemeMode() async {
    final prefs = await _prefs;
    return prefs.getString(_keyThemeMode) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await _prefs;
    await prefs.setString(_keyThemeMode, mode);
  }

  Future<int> getGridColumns() async {
    final prefs = await _prefs;
    return prefs.getInt(_keyGridColumns) ?? 3;
  }

  Future<void> setGridColumns(int columns) async {
    final prefs = await _prefs;
    await prefs.setInt(_keyGridColumns, columns);
  }
}
