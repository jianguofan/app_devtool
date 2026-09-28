import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// A single memory sample (process RSS in bytes).
class MemorySample {
  const MemorySample({required this.at, required this.rssBytes});

  final DateTime at;
  final int rssBytes;
}

/// Samples `ProcessInfo.currentRss` on a fixed interval. Bounded history.
/// No-op on web (dart:io unavailable).
class MemoryMonitor extends ChangeNotifier {
  MemoryMonitor({this.interval = const Duration(seconds: 1), int maxSamples = 300})
      : _maxSamples = maxSamples;

  final Duration interval;
  final int _maxSamples;
  final List<MemorySample> _samples = <MemorySample>[];
  Timer? _timer;

  List<MemorySample> get samples => List<MemorySample>.unmodifiable(_samples);

  int? get latestRss => _samples.isEmpty ? null : _samples.last.rssBytes;

  bool get isSupported => !kIsWeb;

  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(interval, (Timer _) => sample());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void sample() {
    if (kIsWeb) return; // dart:io (ProcessInfo) is unavailable on web.
    final int bytes = ProcessInfo.currentRss;
    _samples.add(MemorySample(at: DateTime.now(), rssBytes: bytes));
    while (_samples.length > _maxSamples) {
      _samples.removeAt(0);
    }
    notifyListeners();
  }
}
