import 'devtool_storage.dart';

/// In-memory [DevtoolStorage]. Used as the fallback when the host provides no
/// storage; state lasts only for the session.
class MemoryDevtoolStorage implements DevtoolStorage {
  final Map<String, String> _data = <String, String>{};

  @override
  Future<Set<String>> getKeys() async => Set<String>.unmodifiable(_data.keys);

  @override
  Future<String?> getString(String key) async => _data[key];

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }
}
