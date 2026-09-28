import 'package:dio/dio.dart';

import '../../core/devtool_capability.dart';
import '../../core/devtool_entry.dart';
import '../../core/devtool_host.dart';
import 'weak_network_controller.dart';
import 'weak_network_interceptor.dart';
import 'weak_network_page.dart';

/// A [DevtoolCapability] that simulates weak network conditions on every Dio.
class WeakNetworkCapability extends DevtoolCapability {
  final WeakNetworkController _controller = WeakNetworkController();
  WeakNetworkInterceptor? _interceptor;

  WeakNetworkController get controller => _controller;

  @override
  String get id => 'weak-network';

  @override
  String get name => '模拟弱网';

  @override
  String get description => '模拟延迟、抖动、丢包、超时与断网';

  @override
  bool get enabledByDefault => false;

  @override
  Future<void> onEnable(DevtoolHost host) async {
    final WeakNetworkInterceptor interceptor = WeakNetworkInterceptor(controller: _controller);
    _interceptor = interceptor;
    for (final Dio dio in host.dioInstances) {
      // Appended to the end so it sits closest to the network (outermost).
      dio.interceptors.add(interceptor);
    }
  }

  @override
  Future<void> onDisable(DevtoolHost host) async {
    final WeakNetworkInterceptor? interceptor = _interceptor;
    if (interceptor == null) return;
    for (final Dio dio in host.dioInstances) {
      dio.interceptors.remove(interceptor);
    }
    _interceptor = null;
  }
}

/// Builds the [DevtoolEntry] for a [WeakNetworkCapability].
DevtoolEntry weakNetworkEntry(WeakNetworkCapability capability) {
  return DevtoolEntry(
    id: capability.id,
    name: capability.name,
    group: '网络工具',
    pageBuilder: (context, host) => WeakNetworkPage(controller: capability.controller),
  );
}
