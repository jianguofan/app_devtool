import 'package:shared_preferences/shared_preferences.dart';

import 'devtool_storage.dart';

/// [DevtoolStorage] backed by `shared_preferences`.
class PrefsDevtoolStorage implements DevtoolStorage {
  PrefsDevtoolStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<Set<String>> getKeys() async => _prefs.getKeys();

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
