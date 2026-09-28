import 'package:dio/dio.dart';

import '../../core/devtool_capability.dart';
import '../../core/devtool_entry.dart';
import '../../core/devtool_host.dart';
import 'network_log_interceptor.dart';
import 'network_log_store.dart';
import 'network_panel_page.dart';

/// A [DevtoolCapability] that captures HTTP traffic on every injected Dio.
class NetworkPanelCapability extends DevtoolCapability {
  NetworkPanelCapability({int capacity = 500, int maxBodyLength = 64 * 1024})
      : _store = NetworkLogStore(capacity: capacity),
        _maxBodyLength = maxBodyLength;

  final NetworkLogStore _store;
  final int _maxBodyLength;
  NetworkLogInterceptor? _interceptor;

  NetworkLogStore get store => _store;

  @override
  String get id => 'network-panel';

  @override
  String get name => '网络请求';

  @override
  String get description => '捕获并可视化 HTTP 请求与响应';

  @override
  bool get enabledByDefault => true;

  @override
  Future<void> onEnable(DevtoolHost host) async {
    final NetworkLogInterceptor interceptor = NetworkLogInterceptor(
      store: _store,
      maxBodyLength: _maxBodyLength,
    );
    _interceptor = interceptor;
    for (final Dio dio in host.dioInstances) {
      dio.interceptors.add(interceptor);
    }
  }

  @override
  Future<void> onDisable(DevtoolHost host) async {
    final NetworkLogInterceptor? interceptor = _interceptor;
    if (interceptor == null) return;
    for (final Dio dio in host.dioInstances) {
      dio.interceptors.remove(interceptor);
    }
    _interceptor = null;
  }
}

/// Builds the [DevtoolEntry] for a [NetworkPanelCapability], wiring the page to
/// the capability's store.
DevtoolEntry networkPanelEntry(NetworkPanelCapability capability) {
  return DevtoolEntry(
    id: capability.id,
    name: capability.name,
    group: '网络工具',
    pageBuilder: (context, host) => NetworkPanelPage(store: capability.store),
  );
}
