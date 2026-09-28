import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'fps_monitor.dart';
import 'memory_monitor.dart';
import 'startup_mark.dart';

/// Performance page: FPS, slow frames, startup timing and memory.
class PerfPage extends StatelessWidget {
  const PerfPage({super.key, required this.fps, required this.memory, required this.startup});

  final FpsMonitor fps;
  final MemoryMonitor memory;
  final StartupMark startup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('性能检测')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            '注意：debug 模式帧数据受 JIT 影响被放大，慢帧结论请以 Profile 模式为准。',
            style: TextStyle(color: Colors.orange, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ListenableBuilder(
            listenable: fps,
            builder: (BuildContext context, Widget? _) {
              return _Section(
                title: 'FPS / 卡顿',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('当前 FPS：${fps.fps.toStringAsFixed(0)}'),
                    Text('累计慢帧：${fps.slowFrameCount}'),
                    const SizedBox(height: 8),
                    for (final SlowFrame f in fps.slowFrames.reversed.take(10))
                      Text(
                        'build ${f.buildMs.toStringAsFixed(1)}ms · raster ${f.rasterMs.toStringAsFixed(1)}ms'
                        '${f.route != null ? ' · ${f.route}' : ''}',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _Section(
            title: '启动耗时',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (startup.marks.isEmpty)
                  const Text('暂无埋点')
                else
                  for (final MapEntry<String, Duration> e in startup.marks.entries)
                    Text('${e.key}：${e.value.inMilliseconds}ms'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (memory.isSupported)
            ListenableBuilder(
              listenable: memory,
              builder: (BuildContext context, Widget? _) {
                final int? rss = memory.latestRss;
                return _Section(
                  title: '内存',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(rss == null ? '暂无采样' : 'RSS：${_formatBytes(rss)}'),
                      const SizedBox(height: 8),
                      _MemorySparkline(samples: memory.samples),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// A minimal line chart of memory samples.
class _MemorySparkline extends StatelessWidget {
  const _MemorySparkline({required this.samples});

  final List<MemorySample> samples;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: CustomPaint(painter: _SparklinePainter(samples)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.samples);

  final List<MemorySample> samples;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2) return;
    int maxBytes = samples.first.rssBytes;
    int minBytes = samples.first.rssBytes;
    for (final MemorySample s in samples) {
      maxBytes = math.max(maxBytes, s.rssBytes);
      minBytes = math.min(minBytes, s.rssBytes);
    }
    final int range = math.max(maxBytes - minBytes, 1);

    final Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final Path path = Path();
    for (int i = 0; i < samples.length; i++) {
      final double x = size.width * i / (samples.length - 1);
      final double y = size.height - (samples[i].rssBytes - minBytes) / range * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => oldDelegate.samples != samples;
}
