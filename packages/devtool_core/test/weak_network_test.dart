import 'dart:math';
import 'dart:typed_data';

import 'package:devtool_core/devtool.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeakNetworkController', () {
    test('nextDelayMs returns base + jitter within range', () {
      final WeakNetworkController controller = WeakNetworkController(random: Random(42));
      controller.setDelay(100);
      controller.setJitter(50);

      for (int i = 0; i < 200; i++) {
        final int delay = controller.nextDelayMs();
        expect(delay, inInclusiveRange(100, 150));
      }
    });

    test('shouldDrop honors loss rate', () {
      final WeakNetworkController controller = WeakNetworkController(random: Random(1));
      controller.setLossRate(0);
      expect(controller.shouldDrop(), isFalse);

      controller.setLossRate(1);
      expect(controller.shouldDrop(), isTrue);
    });

    test('apply preset sets parameters', () {
      final WeakNetworkController controller = WeakNetworkController();
      controller.apply(WeakNetworkController.presets.first);

      expect(controller.delayMs, 500);
      expect(controller.lossRate, greaterThan(0));
    });

    test('reset clears all parameters', () {
      final WeakNetworkController controller = WeakNetworkController()
        ..setEnabled(true)
        ..setDelay(100)
        ..setLossRate(0.5);
      controller.reset();

      expect(controller.enabled, isFalse);
      expect(controller.delayMs, 0);
      expect(controller.lossRate, 0);
    });
  });

  group('WeakNetworkInterceptor', () {
    test('offline mode fails immediately', () async {
      final WeakNetworkController controller = WeakNetworkController()
        ..setEnabled(true)
        ..setOffline(true);
      final Dio dio = _dio(controller);

      await expectLater(
        dio.get<dynamic>('https://example.com/api'),
        throwsA(isA<DioException>()),
      );
    });

    test('100% loss drops the request', () async {
      final WeakNetworkController controller = WeakNetworkController()
        ..setEnabled(true)
        ..setLossRate(1.0);
      final Dio dio = _dio(controller);

      await expectLater(
        dio.get<dynamic>('https://example.com/api'),
        throwsA(isA<DioException>()),
      );
    });

    test('fixed delay adds latency', () async {
      final WeakNetworkController controller = WeakNetworkController()
        ..setEnabled(true)
        ..setDelay(60)
        ..setJitter(0);
      final Dio dio = _dio(controller);

      final Stopwatch stopwatch = Stopwatch()..start();
      await dio.get<dynamic>('https://example.com/api');
      stopwatch.stop();

      // Delay applies on both request and response legs.
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(60));
    });

    test('disabled controller passes requests through', () async {
      final WeakNetworkController controller = WeakNetworkController();
      final Dio dio = _dio(controller);

      final Response<dynamic> response = await dio.get<dynamic>('https://example.com/api');
      expect(response.statusCode, 200);
    });
  });

  group('WeakNetworkCapability', () {
    test('injects into all Dio instances and removes on disable', () async {
      final Dio a = Dio()..httpClientAdapter = _MockAdapter();
      final Dio b = Dio()..httpClientAdapter = _MockAdapter();
      final WeakNetworkCapability capability = WeakNetworkCapability();

      await capability.onEnable(DevtoolHost(dioInstances: <Dio>[a, b]));

      expect(a.interceptors.whereType<WeakNetworkInterceptor>(), hasLength(1));
      expect(b.interceptors.whereType<WeakNetworkInterceptor>(), hasLength(1));

      await capability.onDisable(DevtoolHost(dioInstances: <Dio>[a, b]));

      expect(a.interceptors.whereType<WeakNetworkInterceptor>(), isEmpty);
      expect(b.interceptors.whereType<WeakNetworkInterceptor>(), isEmpty);
    });
  });
}

Dio _dio(WeakNetworkController controller) {
  return Dio()
    ..httpClientAdapter = _MockAdapter()
    ..interceptors.add(WeakNetworkInterceptor(controller: controller));
}

class _MockAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString('{"ok":true}', 200, headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}
