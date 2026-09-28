import 'package:flutter/material.dart';

import '../../core/devtool_capability.dart';
import '../../core/devtool_entry.dart';
import '../../core/devtool_host.dart';
import 'fps_monitor.dart';
import 'memory_monitor.dart';
import 'perf_page.dart';
import 'startup_mark.dart';

/// A [DevtoolCapability] for FPS, slow-frame, startup and memory monitoring.
class PerfCapability extends DevtoolCapability {
  final FpsMonitor _fps = FpsMonitor();
  final MemoryMonitor _memory = MemoryMonitor();
  final StartupMark _startup = StartupMark();
  OverlayEntry? _overlay;

  FpsMonitor get fps => _fps;
  MemoryMonitor get memory => _memory;
  StartupMark get startup => _startup;

  @override
  String get id => 'perf-monitor';

  @override
  String get name => '性能检测';

  @override
  String get description => 'FPS、卡顿、启动耗时与内存监控';

  @override
  bool get enabledByDefault => false;

  @override
  Future<void> onEnable(DevtoolHost host) async {
    _applyRefreshRateThreshold();
    _fps.routeProvider = () => _currentRoute(host);
    _fps.start();
    _memory.start();
    _startup.start();
    // Mark first frame once the first frame has been rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startup.mark('firstFrame');
    });
    _insertOverlay(host);
  }

  @override
  Future<void> onDisable(DevtoolHost host) async {
    _fps.stop();
    _memory.stop();
    _overlay?.remove();
    _overlay = null;
  }

  void _applyRefreshRateThreshold() {
    final double hz = WidgetsBinding.instance.platformDispatcher.views.first.display.refreshRate;
    if (hz > 0) {
      _fps.slowFrameThresholdMs = FpsMonitor.thresholdFromRefreshRate(hz);
    }
  }

  String? _currentRoute(DevtoolHost host) {
    final BuildContext? context = host.navigatorKey?.currentContext;
    if (context == null) return null;
    return ModalRoute.of(context)?.settings.name;
  }

  void _insertOverlay(DevtoolHost host) {
    final GlobalKey<NavigatorState>? navigatorKey = host.navigatorKey;
    if (navigatorKey == null) return; // No overlay host provided.
    final OverlayState? overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) {
      // Boot may run before the navigator is ready; retry after first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => _insertOverlay(host));
      return;
    }
    if (_overlay != null) return;
    _overlay = OverlayEntry(builder: (BuildContext _) => FloatingFps(monitor: _fps));
    overlay.insert(_overlay!);
  }
}

/// Builds the [DevtoolEntry] for a [PerfCapability].
DevtoolEntry perfEntry(PerfCapability capability) {
  return DevtoolEntry(
    id: capability.id,
    name: capability.name,
    group: '性能检测',
    pageBuilder: (context, host) => PerfPage(
      fps: capability.fps,
      memory: capability.memory,
      startup: capability.startup,
    ),
  );
}

/// Draggable, non-blocking floating FPS window.
class FloatingFps extends StatefulWidget {
  const FloatingFps({super.key, required this.monitor});

  final FpsMonitor monitor;

  @override
  State<FloatingFps> createState() => _FloatingFpsState();
}

class _FloatingFpsState extends State<FloatingFps> {
  double _left = 0;
  double _top = 60;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _left,
      top: _top,
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          setState(() {
            _left += details.delta.dx;
            _top += details.delta.dy;
          });
        },
        child: Material(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ListenableBuilder(
              listenable: widget.monitor,
              builder: (BuildContext context, Widget? _) => Text(
                'FPS ${widget.monitor.fps.toStringAsFixed(0)} · 慢帧 ${widget.monitor.slowFrameCount}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
