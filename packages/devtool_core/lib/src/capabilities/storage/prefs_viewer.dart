import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../infra/sensitive_data_masker.dart';

/// A single SharedPreferences entry (raw value + display type).
class PrefEntry {
  const PrefEntry({required this.key, required this.value, required this.type});

  final String key;
  final Object? value;
  final String type;
}

/// Reads SharedPreferences entries, applies display masking, and edits values
/// with type-aware setters.
class SharedPreferencesViewer {
  const SharedPreferencesViewer({SensitiveDataMasker? masker})
      : _masker = masker ?? const SensitiveDataMasker();

  final SensitiveDataMasker _masker;

  List<PrefEntry> read(SharedPreferences prefs) {
    final List<PrefEntry> result = <PrefEntry>[];
    for (final String key in prefs.getKeys()) {
      final Object? value = prefs.get(key);
      result.add(PrefEntry(key: key, value: value, type: _typeOf(value)));
    }
    result.sort((PrefEntry a, PrefEntry b) => a.key.compareTo(b.key));
    return result;
  }

  bool isSensitiveKey(String key) => _masker.isSensitiveKey(key);

  /// Returns a display string for [entry], masked unless [reveal] is true.
  String display(PrefEntry entry, bool reveal) {
    final String raw = _pretty(entry.value?.toString());
    if (reveal) return raw;
    if (_masker.isSensitiveKey(entry.key)) return _masker.mask;
    return _masker.maskText(raw);
  }

  /// Type-aware edit: parses [newValue] according to the existing value's type.
  Future<void> edit(SharedPreferences prefs, String key, String newValue) async {
    final Object? raw = prefs.get(key);
    if (raw is int) {
      await prefs.setInt(key, int.parse(newValue));
    } else if (raw is bool) {
      await prefs.setBool(key, newValue.trim().toLowerCase() == 'true');
    } else if (raw is double) {
      await prefs.setDouble(key, double.parse(newValue));
    } else {
      await prefs.setString(key, newValue);
    }
  }

  /// Serializes all entries to a human-readable JSON dump (the "raw" view).
  String rawDump(SharedPreferences prefs) {
    final Map<String, Object?> map = <String, Object?>{};
    for (final String key in prefs.getKeys()) {
      map[key] = prefs.get(key);
    }
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  static String _typeOf(Object? value) {
    if (value == null) return 'null';
    if (value is bool) return 'bool';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is String) return 'String';
    if (value is List) {
      return 'List<${value.isEmpty ? 'dynamic' : _typeOf(value.first)}>';
    }
    return value.runtimeType.toString();
  }

  static String _pretty(String? text) {
    if (text == null) return '(null)';
    try {
      final Object? decoded = jsonDecode(text);
      if (decoded is Map || decoded is List) {
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
    } catch (_) {
      // Not JSON.
    }
    return text;
  }
}
