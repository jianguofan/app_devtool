import 'dart:convert';

import 'devtool_storage.dart';

/// Persists the enabled/disabled state of every capability.
///
/// Stores a single JSON map (`id -> bool`) so that "explicitly disabled" is
/// distinguishable from "never recorded" — which is what makes first-run
/// defaults work without overriding a user's opt-out.
class DevtoolConfig {
  DevtoolConfig({required this.storage});

  static const String _storageKey = 'devtool.enabled';

  final DevtoolStorage storage;

  Map<String, bool> _states = <String, bool>{};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    final String? raw = await storage.getString(_storageKey);
    _states = <String, bool>{};
    if (raw != null && raw.isNotEmpty) {
      try {
        final Object? decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _states = decoded.map((String key, dynamic value) =>
              MapEntry<String, bool>(key, value == true));
        }
      } on FormatException {
        _states = <String, bool>{};
      }
    }
    _loaded = true;
  }

  bool hasRecord(String id) => _states.containsKey(id);

  bool isEnabled(String id) => _states[id] ?? false;

  Future<void> setEnabled(String id, bool enabled) async {
    _states[id] = enabled;
    await _persist();
  }

  Future<void> _persist() async {
    await storage.setString(_storageKey, jsonEncode(_states));
  }
}
