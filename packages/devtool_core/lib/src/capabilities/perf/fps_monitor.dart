import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../infra/ring_buffer.dart';

/// A single slow (janky) frame.
class SlowFrame {
  const SlowFrame({required this.buildMs, required this.rasterMs, required this.at, this.route});

  final double buildMs;
  final double rasterMs;
  final DateTime at;
  final String? route;
}

/// Samples FPS via `SchedulerBinding.addTimingsCallback` and records slow
/// frames. [recordFrame] is the single testable entry point.
class FpsMonitor extends ChangeNotifier {
  FpsMonitor({this.slowFrameThresholdMs = 16.7, int slowFrameHistory = 100})
      : _slowFrames = RingBuffer<SlowFrame>(slowFrameHistory);

  /// Jank threshold, adjustable for the device refresh rate.
  double slowFrameThresholdMs;
  final RingBuffer<SlowFrame> _slowFrames;
  final List<DateTime> _frameTimes = <DateTime>[];

  /// Optional provider of the current route name, attached to slow frames.
  String? Function()? routeProvider;

  double _fps = 0;
  int _slowFrameCount = 0;

  double get fps => _fps;
  int get slowFrameCount => _slowFrameCount;
  List<SlowFrame> get slowFrames => _slowFrames.toList(growable: false);

  /// Frame budget in ms for a given display refresh rate (Hz).
  static double thresholdFromRefreshRate(double hz) => hz > 0 ? 1000.0 / hz : 16.7;

  // Cached so `start` and `stop` pass the SAME tear-off instance — method
  // tear-offs are fresh objects on each access, and `removeTimingsCallback`
  // compares by identity.
  late final void Function(List<FrameTiming>) _timingsCallback = _onTimings;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addTimingsCallback(_timingsCallback);
  }

  void stop() {
    if (!_started) return;
    _started = false;
    WidgetsBinding.instance.removeTimingsCallback(_timingsCallback);
  }

  void reset() {
    _fps = 0;
    _slowFrameCount = 0;
    _frameTimes.clear();
    _slowFrames.clear();
    notifyListeners();
  }

  void _onTimings(List<FrameTiming> timings) {
    final DateTime now = DateTime.now();
    for (final FrameTiming timing in timings) {
      recordFrame(
        timing.buildDuration.inMicroseconds / 1000.0,
        timing.rasterDuration.inMicroseconds / 1000.0,
        now,
      );
    }
  }

  @visibleForTesting
  void recordFrame(double buildMs, double rasterMs, DateTime at) {
    _frameTimes.add(at);
    final DateTime cutoff = at.subtract(const Duration(seconds: 1));
    _frameTimes.removeWhere((DateTime t) => t.isBefore(cutoff));
    _fps = _frameTimes.length.toDouble();

    if (buildMs > slowFrameThresholdMs || rasterMs > slowFrameThresholdMs) {
      _slowFrameCount++;
      _slowFrames.add(SlowFrame(
        buildMs: buildMs,
        rasterMs: rasterMs,
        at: at,
        route: routeProvider?.call(),
      ));
    }
    notifyListeners();
  }
}
