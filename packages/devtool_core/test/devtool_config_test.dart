import 'package:devtool_core/devtool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DevtoolConfig', () {
    test('persists and reloads enabled state', () async {
      final MemoryDevtoolStorage storage = MemoryDevtoolStorage();
      final DevtoolConfig config = DevtoolConfig(storage: storage);
      await config.load();
      await config.setEnabled('network-panel', true);

      final DevtoolConfig reloaded = DevtoolConfig(storage: storage);
      await reloaded.load();

      expect(reloaded.isEnabled('network-panel'), isTrue);
      expect(reloaded.hasRecord('network-panel'), isTrue);
    });

    test('distinguishes explicit disable from never recorded', () async {
      final MemoryDevtoolStorage storage = MemoryDevtoolStorage();
      final DevtoolConfig config = DevtoolConfig(storage: storage);
      await config.load();

      expect(config.hasRecord('x'), isFalse);

      await config.setEnabled('x', false);
      expect(config.hasRecord('x'), isTrue);
      expect(config.isEnabled('x'), isFalse);
    });

    test('defaults to disabled when no record exists', () async {
      final DevtoolConfig config =
          DevtoolConfig(storage: MemoryDevtoolStorage());
      await config.load();
      expect(config.isEnabled('missing'), isFalse);
    });

    test('tolerates corrupted persisted payload', () async {
      final MemoryDevtoolStorage storage = MemoryDevtoolStorage();
      await storage.setString('devtool.enabled', 'not-json');

      final DevtoolConfig config = DevtoolConfig(storage: storage);
      await config.load();

      expect(config.isLoaded, isTrue);
      expect(config.isEnabled('anything'), isFalse);
    });
  });
}
