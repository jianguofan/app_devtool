import 'package:devtool_core/devtool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RingBuffer', () {
    test('adds up to capacity', () {
      final RingBuffer<int> buffer = RingBuffer<int>(3);
      buffer.add(1);
      buffer.add(2);

      expect(buffer.length, 2);
      expect(buffer.toList(), <int>[1, 2]);
      expect(buffer.isEmpty, isFalse);
      expect(buffer.isFull, isFalse);
    });

    test('evicts oldest when full', () {
      final RingBuffer<int> buffer = RingBuffer<int>(3);
      buffer.add(1);
      buffer.add(2);
      buffer.add(3);
      buffer.add(4);

      expect(buffer.length, 3);
      expect(buffer.isFull, isTrue);
      expect(buffer.toList(), <int>[2, 3, 4]);
      expect(buffer[0], 2);
    });

    test('indexing and iteration match insertion order', () {
      final RingBuffer<String> buffer = RingBuffer<String>(2);
      buffer.add('a');
      buffer.add('b');
      buffer.add('c');

      final List<String> collected = buffer.toList();
      expect(collected, <String>['b', 'c']);
      expect(buffer[0], 'b');
      expect(buffer[1], 'c');
    });

    test('clear resets to empty', () {
      final RingBuffer<int> buffer = RingBuffer<int>(2);
      buffer.add(1);
      buffer.add(2);
      buffer.clear();

      expect(buffer.isEmpty, isTrue);
      expect(buffer.length, 0);
    });

    test('rejects non-positive capacity', () {
      expect(() => RingBuffer<int>(0), throwsAssertionError);
    });
  });
}
