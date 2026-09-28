import 'dart:convert';

import 'package:dio/dio.dart';

import '../../infra/sensitive_data_masker.dart';
import 'network_log_entry.dart';
import 'network_log_store.dart';

/// Captures requests/responses into a [NetworkLogStore].
///
/// Correlates each request with its response via `options.extra`, and masks
/// sensitive data at write time. The interceptor never throws — debugging must
/// not break the business request.
class NetworkLogInterceptor extends Interceptor {
  NetworkLogInterceptor({
    required this.store,
    SensitiveDataMasker? masker,
    this.maxBodyLength = 64 * 1024,
  }) : _masker = masker ?? const SensitiveDataMasker();

  static const String _extraKey = '_devtool_netlog_id';

  final NetworkLogStore store;
  final SensitiveDataMasker _masker;
  final int maxBodyLength;

  final Map<int, _PendingRequest> _pending = <int, _PendingRequest>{};
  int _nextId = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final int id = _nextId++;
      options.extra[_extraKey] = id;
      final (String? requestBody, _) = _processBody(options.data);
      _pending[id] = _PendingRequest(
        id: id,
        startAt: DateTime.now(),
        method: options.method,
        url: options.uri.toString(),
        requestHeaders: _maskHeaders(options.headers),
        requestBody: requestBody,
      );
    } catch (_) {
      // Ignore.
    }
    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    try {
      final _PendingRequest? pending = _takePending(response.requestOptions);
      if (pending != null) {
        final Map<String, dynamic> responseHeaders = response.headers.map;
        final bool isStream =
            response.requestOptions.responseType == ResponseType.stream;
        final (String? responseBody, bool truncated) =
            isStream ? ('<stream>', false) : _processBody(response.data);
        store.add(NetworkLogEntry(
          id: pending.id,
          method: pending.method,
          url: pending.url,
          statusCode: response.statusCode,
          startAt: pending.startAt,
          duration: DateTime.now().difference(pending.startAt),
          requestHeaders: pending.requestHeaders,
          requestBody: pending.requestBody,
          responseHeaders: _maskHeaders(responseHeaders),
          responseBody: responseBody,
          traceId: _extractTraceId(responseHeaders),
          truncated: truncated,
        ));
      }
    } catch (_) {
      // Ignore.
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      final _PendingRequest? pending = _takePending(err.requestOptions);
      if (pending != null) {
        final Map<String, dynamic> responseHeaders =
            err.response?.headers.map ?? const <String, dynamic>{};
        final (String? responseBody, bool truncated) = err.response == null
            ? (null, false)
            : _processBody(err.response!.data);
        store.add(NetworkLogEntry(
          id: pending.id,
          method: pending.method,
          url: pending.url,
          statusCode: err.response?.statusCode,
          startAt: pending.startAt,
          duration: DateTime.now().difference(pending.startAt),
          requestHeaders: pending.requestHeaders,
          requestBody: pending.requestBody,
          responseHeaders: _maskHeaders(responseHeaders),
          responseBody: responseBody,
          error: err.message ?? err.type.name,
          traceId: _extractTraceId(responseHeaders),
          truncated: truncated,
        ));
      }
    } catch (_) {
      // Ignore.
    }
    handler.next(err);
  }

  _PendingRequest? _takePending(RequestOptions options) {
    final Object? raw = options.extra[_extraKey];
    if (raw is! int) return null;
    return _pending.remove(raw);
  }

  /// Converts request/response data to a masked, truncated string plus whether
  /// it was truncated.
  (String?, bool) _processBody(dynamic data) {
    final String? raw = _bodyToString(data);
    if (raw == null) return (null, false);
    final String masked = _masker.maskText(raw);
    if (masked.length <= maxBodyLength) {
      return (masked, false);
    }
    return ('${masked.substring(0, maxBodyLength)}…<truncated>', true);
  }

  Map<String, String> _maskHeaders(Map<String, dynamic>? headers) {
    if (headers == null) return const <String, String>{};
    final Map<String, String> result = <String, String>{};
    headers.forEach((String key, dynamic value) {
      result[key] =
          _masker.isSensitiveKey(key) ? _masker.mask : _stringify(value);
    });
    return result;
  }

  String? _bodyToString(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map || data is List) return jsonEncode(data);
    if (data is FormData) return '<FormData>';
    if (data is List<int>) return '<binary ${data.length} bytes>';
    return data.toString();
  }

  static String _stringify(dynamic value) {
    if (value is List) return value.join(', ');
    return '$value';
  }

  static String? _extractTraceId(Map<String, dynamic>? headers) {
    if (headers == null) return null;
    for (final String key in headers.keys) {
      final String lower = key.toLowerCase();
      if (lower == 'trace-id' || lower == 'x-request-id') {
        return _stringify(headers[key]);
      }
    }
    return null;
  }
}

class _PendingRequest {
  _PendingRequest({
    required this.id,
    required this.startAt,
    required this.method,
    required this.url,
    required this.requestHeaders,
    required this.requestBody,
  });

  final int id;
  final DateTime startAt;
  final String method;
  final String url;
  final Map<String, String> requestHeaders;
  final String? requestBody;
}
