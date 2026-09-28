/// Masks sensitive fields (tokens, passwords, cookies, phone numbers) before
/// data is written to a buffer or exported. Masking happens at write time so
/// that exports and copies never leak the original value.
class SensitiveDataMasker {
  const SensitiveDataMasker({this.mask = '***'});

  final String mask;

  static final RegExp _sensitiveKey = RegExp(
    r'(authorization|token|password|passwd|secret|cookie|session|api[_-]?key|phone|mobile)',
    caseSensitive: false,
  );

  static final RegExp _phoneNumber = RegExp(r'\b1[3-9]\d{9}\b');

  static final RegExp _jsonSensitiveValue = RegExp(
    r'("(?:[^"]*(?:token|password|passwd|secret|authorization|cookie|session|api[_-]?key)[^"]*)"\s*:\s*")[^"]*(")',
    caseSensitive: false,
  );

  bool isSensitiveKey(String key) => _sensitiveKey.hasMatch(key);

  /// Masks a single key name (used to redact storage keys themselves).
  String maskKey(String key) => isSensitiveKey(key) ? mask : key;

  /// Masks values whose key name is sensitive (e.g. headers).
  Map<String, String> maskMap(Map<String, String>? map) {
    if (map == null) return const <String, String>{};
    return map.map((String key, String value) =>
        MapEntry<String, String>(key, isSensitiveKey(key) ? mask : value));
  }

  /// Masks phone numbers and JSON values under sensitive keys within free text.
  String maskText(String? text) {
    if (text == null || text.isEmpty) return text ?? '';
    String result = text;
    result = result.replaceAllMapped(_phoneNumber, (Match m) => mask);
    result = result.replaceAllMapped(
        _jsonSensitiveValue, (Match m) => '${m[1]}$mask${m[2]}');
    return result;
  }
}
