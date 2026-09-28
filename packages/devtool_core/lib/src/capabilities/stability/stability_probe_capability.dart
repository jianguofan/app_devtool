import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

import '../../core/devtool_capability.dart';
import '../../core/devtool_entry.dart';
import 'stability_page.dart';
import 'stability_reporter.dart';

/// A [DevtoolCapability] that triggers crashes/errors to verify the monitoring
/// pipeline. Destructive probes are internal-build only.
class StabilityProbeCapability extends DevtoolCapability {
  StabilityProbeCapability({this.reporter, this.nativeCrash});

  /// Reports non-fatal errors/custom events (host-provided Sentry/Crashlytics).
  final StabilityReporter? reporter;

  /// Triggers a native crash (host-provided; e.g. a MethodChannel to native).
  final Future<void> Function()? nativeCrash;

  @override
  String get id => 'stability-probe';

  @override
  String get name => '稳定性探针';

  @override
  String get description => '触发各类异常/崩溃以验证监控链路';

  @override
  bool get enabledByDefault => false;

  /// Monitoring environment and authorization state (from [reporter]).
  MonitoringInfo get info => reporter?.info ?? const MonitoringInfo();

  /// Throws an uncaught Dart exception (outside any guarded zone).
  void throwDartException() {
    Future<void>(() => throw StateError('devtool: dart uncaught probe'));
  }

  /// Reports a Flutter framework exception via [FlutterError.reportError].
  void throwFlutterException() {
    FlutterError.reportError(FlutterErrorDetails(
      exception: StateError('devtool: flutter framework probe'),
      library: 'devtool',
      context: ErrorDescription('stability probe'),
    ));
  }

  /// Throws an uncaught exception in a new isolate.
  Future<void> throwIsolateException() async {
    await Isolate.run(() => throw StateError('devtool: isolate probe'));
  }

  /// Reports a non-fatal error through [reporter].
  void captureNonFatal() {
    reporter?.captureException(StateError('devtool: non-fatal probe'), StackTrace.current);
  }

  /// Sends a custom event + breadcrumb through [reporter].
  void captureCustomEvent() {
    reporter?.captureMessage('devtool: custom event probe');
    reporter?.addBreadcrumb('devtool breadcrumb');
  }

  /// Allocates memory in chunks to stress the runtime (OOM probe). Graded by
  /// [megabytes] so callers can escalate pressure (64 / 128 / 256 MB, etc.).
  void triggerOom({int megabytes = 64}) {
    final List<List<int>> chunks = <List<int>>[];
    for (int i = 0; i < megabytes; i++) {
      chunks.add(List<int>.filled(1024 * 1024, 0));
    }
  }

  /// Triggers a native crash through the host-provided callback.
  Future<void> triggerNativeCrash() async {
    final Future<void> Function()? fn = nativeCrash;
    if (fn == null) {
      throw StateError('native crash module not installed');
    }
    await fn();
  }
}

/// Builds the [DevtoolEntry] for a [StabilityProbeCapability].
DevtoolEntry stabilityEntry(StabilityProbeCapability capability) {
  return DevtoolEntry(
    id: capability.id,
    name: capability.name,
    group: '日志与稳定性',
    pageBuilder: (context, host) => StabilityPage(capability: capability),
  );
}
