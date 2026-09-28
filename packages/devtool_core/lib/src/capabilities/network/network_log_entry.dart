/// An immutable snapshot of a single HTTP request/response exchange.
class NetworkLogEntry {
  const NetworkLogEntry({
    required this.id,
    required this.method,
    required this.url,
    required this.startAt,
    required this.duration,
    this.statusCode,
    this.requestHeaders = const <String, String>{},
    this.requestBody,
    this.responseHeaders = const <String, String>{},
    this.responseBody,
    this.error,
    this.traceId,
    this.truncated = false,
  });

  final int id;
  final String method;
  final String url;
  final int? statusCode;
  final DateTime startAt;
  final Duration duration;
  final Map<String, String> requestHeaders;
  final String? requestBody;
  final Map<String, String> responseHeaders;
  final String? responseBody;
  final String? error;
  final String? traceId;

  /// Whether a request or response body was truncated to a size cap.
  final bool truncated;

  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 400;

  /// Reconstructs an equivalent cURL command from the stored (already masked)
  /// data.
  String toCurl() {
    final List<String> parts = <String>['curl', '-X', method, "'$url'"];
    requestHeaders.forEach((String key, String value) {
      parts.add("-H '$key: $value'");
    });
    final String? body = requestBody;
    if (body != null && body.isNotEmpty) {
      parts.add("-d '$body'");
    }
    return parts.join(' ');
  }
}
