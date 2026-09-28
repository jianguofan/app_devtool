import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import '../storage/devtool_storage.dart';

/// Resources the host app hands to the kernel.
///
/// Capabilities reach host objects (Dio instances, navigator, storage) through
/// this context rather than importing the host app — the inversion that keeps
/// the toolkit decoupled from any single app.
class DevtoolHost {
  const DevtoolHost({
    this.dioInstances = const <Dio>[],
    this.navigatorKey,
    this.storage,
  });

  /// All Dio instances the host wants debug capabilities to observe.
  final List<Dio> dioInstances;

  /// Root navigator key, used to reach the app's overlay (e.g. floating FPS).
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Persistence for toggle state. When omitted, [MemoryDevtoolStorage] is used.
  final DevtoolStorage? storage;
}
