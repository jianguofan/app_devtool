import 'dart:typed_data';

import 'package:devtool_core/devtool.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkLogInterceptor', () {
    test('captures a successful request', () async {
      final NetworkLogStore store = NetworkLogStore();
      final Dio dio = _dio(store, body: '{"result":"ok"}');

      await dio.get<dynamic>('https://example.com/api/users');

      expect(store.entries, hasLength(1));
      final NetworkLogEntry entry = store.entries.first;
      expect(entry.method, 'GET');
      expect(entry.url, 'https://example.com/api/users');
      expect(entry.statusCode, 200);
      expect(entry.isSuccess, isTrue);
      expect(entry.error, isNull);
    });

    test('captures failure reason', () async {
      final NetworkLogStore store = NetworkLogStore();
      final Dio dio =
          _dio(store, statusCode: 404, body: '{"error":"not found"}');

      await expectLater(
        dio.get<dynamic>('https://example.com/missing'),
        throwsA(isA<DioException>()),
      );

      expect(store.entries, hasLength(1));
      final NetworkLogEntry entry = store.entries.first;
      expect(entry.statusCode, 404);
      expect(entry.isSuccess, isFalse);
      expect(entry.error, isNotNull);
    });

    test('correlates concurrent requests via extra id', () async {
      final NetworkLogStore store = NetworkLogStore();
      final Dio dio = _dio(store);

      await Future.wait(<Future<void>>[
        dio.get<dynamic>('https://example.com/a'),
        dio.get<dynamic>('https://example.com/b'),
        dio.get<dynamic>('https://example.com/c'),
      ]);

      expect(store.entries, hasLength(3));
      final Set<String> urls =
          store.entries.map((NetworkLogEntry e) => e.url).toSet();
      expect(
        urls,
        containsAll(<String>[
          'https://example.com/a',
          'https://example.com/b',
          'https://example.com/c',
        ]),
      );
    });

    test('masks sensitive data before storage', () async {
      final NetworkLogStore store = NetworkLogStore();
      final Dio dio = _dio(store, body: '{"token":"secret123"}');
      dio.options.headers['Authorization'] = 'Bearer abc123';

      await dio.get<dynamic>('https://example.com/api');

      final NetworkLogEntry entry = store.entries.first;
      expect(entry.requestHeaders['Authorization'], '***');
      expect(entry.responseBody, contains('***'));
      expect(entry.responseBody, isNot(contains('secret123')));
    });

    test('extracts trace id from response headers', () async {
      final NetworkLogStore store = NetworkLogStore();
      final Dio dio = _dio(
        store,
        headers: <String, List<String>>{
          'x-request-id': <String>['trace-42']
        },
      );

      await dio.get<dynamic>('https://example.com/api');

      expect(store.entries.first.traceId, 'trace-42');
    });

    test('cURL output contains method and url', () async {
      final NetworkLogStore store = NetworkLogStore();
      final Dio dio = _dio(store);

      await dio.post<dynamic>('https://example.com/api',
          data: <String, Object>{'x': 1});

      final String curl = store.entries.first.toCurl();
      expect(curl, contains('POST'));
      expect(curl, contains('https://example.com/api'));
    });
  });

  group('NetworkLogStore', () {
    test('is bounded and evicts oldest', () {
      final NetworkLogStore store = NetworkLogStore(capacity: 2);
      store.add(_entry(1));
      store.add(_entry(2));
      store.add(_entry(3));

      expect(store.entries, hasLength(2));
      expect(
          store.entries.map((NetworkLogEntry e) => e.id).toList(), <int>[2, 3]);
    });

    test('clear removes all entries', () {
      final NetworkLogStore store = NetworkLogStore();
      store.add(_entry(1));
      store.clear();
      expect(store.entries, isEmpty);
    });
  });
}

Dio _dio(
  NetworkLogStore store, {
  int statusCode = 200,
  String body = '{}',
  Map<String, List<String>> headers = const <String, List<String>>{},
}) {
  final NetworkLogInterceptor interceptor = NetworkLogInterceptor(store: store);
  return Dio()
    ..httpClientAdapter =
        _MockAdapter(statusCode: statusCode, body: body, headers: headers)
    ..interceptors.add(interceptor);
}

NetworkLogEntry _entry(int id) {
  return NetworkLogEntry(
    id: id,
    method: 'GET',
    url: 'https://example.com/$id',
    startAt: DateTime.now(),
    duration: Duration.zero,
  );
}

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter({
    this.statusCode = 200,
    this.body = '{}',
    this.headers = const <String, List<String>>{},
  });

  final int statusCode;
  final String body;
  final Map<String, List<String>> headers;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
        ...headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
