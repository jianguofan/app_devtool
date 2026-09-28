import 'package:flutter/foundation.dart';

import '../storage/devtool_config.dart';
import '../storage/memory_devtool_storage.dart';
import 'devtool_capability.dart';
import 'devtool_entry.dart';
import 'devtool_host.dart';
import 'devtool_scope.dart';

/// Compile-time switch. Host apps wrap registration in `if (kDevtoolEnabled)`
/// so release builds (which do not define `DEVTOOL_ENABLED`) tree-shake the
/// entire toolkit away.
const bool kDevtoolEnabled = bool.fromEnvironment(
  'DEVTOOL_ENABLED',
  defaultValue: kDebugMode,
);

/// The microkernel.
///
/// Manages registered [DevtoolCapability]s, their persisted enable/disable
/// state and their lifecycle. It depends only on the [DevtoolCapability]
/// abstraction, never on a concrete capability.
class Devtool extends ChangeNotifier {
  Devtool({this.scope = DevtoolScope.debugOnly, this.onError});

  /// Availability boundary; see [DevtoolScope].
  final DevtoolScope scope;

  /// Invoked when a capability's lifecycle callback throws. Defaults to
  /// [debugPrint].
  final void Function(String message, Object error, StackTrace stackTrace)?
      onError;

  /// Optional global convenience instance. Host apps may assign this; the
  /// package never reads it internally.
  static Devtool? instance;

  final Map<String, DevtoolCapability> _capabilities =
      <String, DevtoolCapability>{};
  final Map<String, DevtoolEntry> _entries = <String, DevtoolEntry>{};

  DevtoolHost? _host;
  DevtoolConfig? _config;
  bool _booted = false;

  List<DevtoolCapability> get capabilities =>
      List.unmodifiable(_capabilities.values);
  List<DevtoolEntry> get entries => List.unmodifiable(_entries.values);

  /// Non-null after [boot].
  DevtoolHost? get host => _host;

  /// Whether the toolkit is active under the current scope + compile-time flag.
  bool get isActive {
    if (!kDevtoolEnabled) return false;
    switch (scope) {
      case DevtoolScope.disabled:
        return false;
      case DevtoolScope.debugOnly:
        return kDebugMode;
      case DevtoolScope.internal:
        return kDebugMode || const bool.fromEnvironment('DEVTOOL_INTERNAL');
      case DevtoolScope.enabled:
        return true;
    }
  }

  void register(DevtoolCapability capability) {
    _capabilities[capability.id] = capability;
  }

  void registerEntry(DevtoolEntry entry) {
    _entries[entry.id] = entry;
  }

  bool isEnabled(String id) => _config?.isEnabled(id) ?? false;

  bool isHotSwappable(String id) => _capabilities[id]?.hotSwappable ?? true;

  /// Boots the kernel: loads persisted state and enables active capabilities.
  ///
  /// Idempotent — subsequent calls are no-ops. When [scope] is inactive this
  /// returns immediately without registering or initializing anything.
  Future<void> boot(DevtoolHost host) async {
    if (_booted) return;
    _booted = true;
    _host = host;
    if (!isActive) return;

    _config = DevtoolConfig(storage: host.storage ?? MemoryDevtoolStorage());
    await _config!.load();

    // First-run semantics: apply `enabledByDefault` only when no persisted
    // record exists, so an explicit user opt-out survives restarts.
    for (final DevtoolCapability capability in _capabilities.values) {
      if (!_config!.hasRecord(capability.id)) {
        await _config!.setEnabled(capability.id, capability.enabledByDefault);
      }
    }

    for (final DevtoolCapability capability in _capabilities.values) {
      if (_config!.isEnabled(capability.id)) {
        await _enable(capability);
      }
    }
  }

  /// Toggles a capability. Non-hot-swappable capabilities only persist state and
  /// take effect on the next boot.
  Future<void> setEnabled(String id, bool enabled) async {
    if (!isActive) return;
    final DevtoolCapability? capability = _capabilities[id];
    final DevtoolConfig? config = _config;
    if (capability == null || config == null) return;

    await config.setEnabled(id, enabled);
    if (!capability.hotSwappable) {
      notifyListeners();
      return;
    }
    if (enabled) {
      await _enable(capability);
    } else {
      await _disable(capability);
    }
    notifyListeners();
  }

  Future<void> _enable(DevtoolCapability capability) async {
    try {
      await capability.onEnable(_host!);
    } catch (error, stackTrace) {
      _report('devtool: enable "${capability.id}" failed', error, stackTrace);
    }
  }

  Future<void> _disable(DevtoolCapability capability) async {
    try {
      await capability.onDisable(_host!);
    } catch (error, stackTrace) {
      _report('devtool: disable "${capability.id}" failed', error, stackTrace);
    }
  }

  void _report(String message, Object error, StackTrace stackTrace) {
    final void Function(String, Object, StackTrace)? handler = onError;
    if (handler != null) {
      handler(message, error, stackTrace);
    } else {
      debugPrint('$message: $error\n$stackTrace');
    }
  }
}
