import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Parses "Key: Value" lines (one per line) into a header map.
Map<String, String> parseHeaders(String text) {
  final Map<String, String> result = <String, String>{};
  for (final String line in text.split('\n')) {
    final int idx = line.indexOf(':');
    if (idx > 0) {
      final String key = line.substring(0, idx).trim();
      final String value = line.substring(idx + 1).trim();
      if (key.isNotEmpty) result[key] = value;
    }
  }
  return result;
}

/// Formats a JavaScript evaluation result for display (objects → pretty JSON).
String formatJsResult(dynamic result) {
  if (result == null) return '(null)';
  if (result is Map || result is List) {
    return const JsonEncoder.withIndent('  ').convert(result);
  }
  return result.toString();
}

/// Builds a [URLRequest] with headers parsed from [headersText].
URLRequest buildRequest(String url, String headersText) {
  return URLRequest(url: WebUri(url), headers: parseHeaders(headersText));
}
