/// Key-value persistence abstraction for the toolkit.
///
/// Decouples toggle-state persistence from `shared_preferences`, so a host can
/// pass a different backend or none at all (falling back to memory).
abstract class DevtoolStorage {
  Future<Set<String>> getKeys();

  Future<String?> getString(String key);

  Future<void> setString(String key, String value);

  Future<void> remove(String key);
}
