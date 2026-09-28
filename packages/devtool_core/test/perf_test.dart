import 'package:devtool_core/devtool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FpsMonitor', () {
    test('records slow frames above threshold', () {
      final FpsMonitor monitor = FpsMonitor(slowFrameThresholdMs: 16.7);
      final DateTime now = DateTime.now();

      monitor.recordFrame(20, 5, now); // build jank
      monitor.recordFrame(5, 30, now); // raster jank
      monitor.recordFrame(8, 8, now); // ok

      expect(monitor.slowFrameCount, 2);
      expect(monitor.slowFrames, hasLength(2));
    });

    test('computes fps as frames within the last second', () {
      final FpsMonitor monitor = FpsMonitor();
      final DateTime t0 = DateTime.now();

      for (int i = 0; i < 60; i++) {
        monitor.recordFrame(10, 10, t0);
      }
      expect(monitor.fps, 60);

      // After 2s, the previous batch falls out of the one-second window.
      final DateTime t2 = t0.add(const Duration(seconds: 2));
      for (int i = 0; i < 30; i++) {
        monitor.recordFrame(10, 10, t2);
      }
      expect(monitor.fps, 30);
    });

    test('slow frame history is bounded', () {
      final FpsMonitor monitor = FpsMonitor(slowFrameHistory: 3);
      final DateTime now = DateTime.now();
      for (int i = 0; i < 10; i++) {
        monitor.recordFrame(20, 20, now);
      }
      expect(monitor.slowFrames, hasLength(3));
    });
  });

  group('StartupMark', () {
    test('marks milestones and computes intervals', () {
      final StartupMark mark = StartupMark()..start();
      mark.mark('main');
      mark.mark('firstFrame');
      mark.mark('interactive');

      expect(mark.marks, contains('main'));
      expect(mark.elapsed('firstFrame'), isNotNull);
      expect(mark.between('main', 'firstFrame'), isNotNull);
      expect(mark.between('main', 'missing'), isNull);
    });
  });
}
