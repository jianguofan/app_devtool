/// Native bridge for `devtool`.
///
/// A Flutter plugin whose Android/iOS side registers a `crash` method that
/// deliberately crashes the native runtime, used by the stability probe.
library;

import 'package:flutter/services.dart';

/// Triggers a native crash through the plugin's `crash` method.
class NativeCrashChannel {
  const NativeCrashChannel();

  static const MethodChannel _channel = MethodChannel('devtool_native');

  /// Invokes the `crash` method. The plugin's native side crashes the process.
  Future<void> crash() async {
    await _channel.invokeMethod<void>('crash');
  }
}
