import 'package:dio/dio.dart';

import 'weak_network_controller.dart';

/// Injects delay, jitter, packet loss, timeout and offline into the request
/// path. Added at the outermost position so it simulates the whole link.
class WeakNetworkInterceptor extends Interceptor {
  WeakNetworkInterceptor({required this.controller});

  final WeakNetworkController controller;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!controller.enabled) {
      handler.next(options);
      return;
    }
    if (controller.offline) {
      handler.reject(_error(options, '模拟断网', DioExceptionType.connectionError));
      return;
    }
    if (controller.shouldDrop()) {
      handler.reject(_error(options, '模拟丢包', DioExceptionType.connectionError));
      return;
    }
    if (controller.timeoutMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: controller.timeoutMs));
      handler.reject(_error(options, '模拟超时', DioExceptionType.connectionTimeout));
      return;
    }
    final int delay = controller.nextDelayMs();
    if (delay > 0) {
      await Future<void>.delayed(Duration(milliseconds: delay));
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) async {
    if (controller.enabled) {
      final int delay = controller.nextDelayMs();
      if (delay > 0) {
        await Future<void>.delayed(Duration(milliseconds: delay));
      }
    }
    handler.next(response);
  }

  DioException _error(RequestOptions options, String message, DioExceptionType type) {
    return DioException(requestOptions: options, type: type, message: message);
  }
}
