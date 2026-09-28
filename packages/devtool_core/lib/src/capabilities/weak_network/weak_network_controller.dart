import 'dart:math';

import 'package:flutter/foundation.dart';

/// A preset weak-network scenario.
class WeakNetworkProfile {
  const WeakNetworkProfile({
    required this.name,
    required this.delayMs,
    this.jitterMs = 0,
    this.lossRate = 0,
  });

  final String name;
  final int delayMs;
  final int jitterMs;
  final double lossRate;
}

/// Holds weak-network parameters. The interceptor reads from it; the UI writes.
class WeakNetworkController extends ChangeNotifier {
  WeakNetworkController({Random? random}) : _random = random ?? Random();

  static const List<WeakNetworkProfile> presets = <WeakNetworkProfile>[
    WeakNetworkProfile(name: '2G', delayMs: 500, jitterMs: 200, lossRate: 0.10),
    WeakNetworkProfile(name: '3G', delayMs: 150, jitterMs: 100, lossRate: 0.02),
    WeakNetworkProfile(name: '弱 Wi-Fi', delayMs: 50, jitterMs: 50, lossRate: 0.05),
  ];

  final Random _random;

  bool _enabled = false;
  bool _offline = false;
  int _delayMs = 0;
  int _jitterMs = 0;
  double _lossRate = 0;
  int _timeoutMs = 0;

  bool get enabled => _enabled;
  bool get offline => _offline;
  int get delayMs => _delayMs;
  int get jitterMs => _jitterMs;
  double get lossRate => _lossRate;
  int get timeoutMs => _timeoutMs;

  void setEnabled(bool value) {
    _enabled = value;
    notifyListeners();
  }

  void setOffline(bool value) {
    _offline = value;
    notifyListeners();
  }

  void setDelay(int ms) {
    _delayMs = ms;
    notifyListeners();
  }

  void setJitter(int ms) {
    _jitterMs = ms;
    notifyListeners();
  }

  void setLossRate(double rate) {
    _lossRate = rate.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setTimeout(int ms) {
    _timeoutMs = ms;
    notifyListeners();
  }

  void apply(WeakNetworkProfile profile) {
    _delayMs = profile.delayMs;
    _jitterMs = profile.jitterMs;
    _lossRate = profile.lossRate;
    _timeoutMs = 0;
    notifyListeners();
  }

  void reset() {
    _enabled = false;
    _offline = false;
    _delayMs = 0;
    _jitterMs = 0;
    _lossRate = 0;
    _timeoutMs = 0;
    notifyListeners();
  }

  /// Whether the next request should be dropped, based on [lossRate].
  bool shouldDrop() => _lossRate > 0 && _random.nextDouble() < _lossRate;

  /// The delay for the next leg, in milliseconds.
  int nextDelayMs() {
    if (_timeoutMs > 0) return _timeoutMs;
    if (_delayMs <= 0) return 0;
    return _delayMs + _random.nextInt(_jitterMs + 1);
  }
}
