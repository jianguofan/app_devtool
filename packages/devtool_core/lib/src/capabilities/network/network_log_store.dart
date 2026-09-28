import 'package:flutter/foundation.dart';

import '../../infra/ring_buffer.dart';
import 'network_log_entry.dart';

/// Holds captured network entries in a bounded ring buffer and notifies UI on
/// change. Memory stays bounded regardless of how long the app runs.
class NetworkLogStore extends ChangeNotifier {
  NetworkLogStore({int capacity = 500})
      : assert(capacity > 0),
        _entries = RingBuffer<NetworkLogEntry>(capacity);

  final RingBuffer<NetworkLogEntry> _entries;

  List<NetworkLogEntry> get entries => _entries.toList(growable: false);

  void add(NetworkLogEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}
