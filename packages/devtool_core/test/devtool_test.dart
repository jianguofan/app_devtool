import 'package:devtool_core/devtool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Devtool', () {
    test('boot enables only enabled capabilities', () async {
      final _FakeCapability a = _FakeCapability('a', enabledByDefault: true);
      final _FakeCapability b = _FakeCapability('b');
      final Devtool devtool = Devtool(scope: DevtoolScope.enabled)
        ..register(a)
        ..register(b);

      await devtool.boot(const DevtoolHost());

      expect(a.enableCount, 1);
      expect(b.enableCount, 0);
      expect(devtool.isEnabled('a'), isTrue);
      expect(devtool.isEnabled('b'), isFalse);
    });

    test('setEnabled triggers onEnable and onDisable', () async {
      final _FakeCapability a = _FakeCapability('a');
      final Devtool devtool = Devtool(scope: DevtoolScope.enabled)..register(a);
      await devtool.boot(const DevtoolHost());

      await devtool.setEnabled('a', true);
      expect(a.enableCount, 1);

      await devtool.setEnabled('a', false);
      expect(a.disableCount, 1);
      expect(devtool.isEnabled('a'), isFalse);
    });

    test('failure isolation: throwing capability does not break others',
        () async {
      final _FakeCapability bad =
          _FakeCapability('bad', enabledByDefault: true, throwOnEnable: true);
      final _FakeCapability good =
          _FakeCapability('good', enabledByDefault: true);
      final Devtool devtool = Devtool(scope: DevtoolScope.enabled)
        ..register(bad)
        ..register(good);

      await devtool.boot(const DevtoolHost());

      expect(good.enableCount, 1);
    });

    test('disabled scope is a no-op', () async {
      final _FakeCapability a = _FakeCapability('a', enabledByDefault: true);
      final Devtool devtool = Devtool(scope: DevtoolScope.disabled)
        ..register(a);

      await devtool.boot(const DevtoolHost());

      expect(a.enableCount, 0);
      expect(devtool.isEnabled('a'), isFalse);
    });

    test('non-hot-swappable disable does not call onDisable', () async {
      final _FakeCapability a =
          _FakeCapability('a', enabledByDefault: true, hotSwappable: false);
      final Devtool devtool = Devtool(scope: DevtoolScope.enabled)..register(a);
      await devtool.boot(const DevtoolHost());

      await devtool.setEnabled('a', false);

      expect(a.disableCount, 0);
      expect(devtool.isEnabled('a'), isFalse);
    });

    test('first-run default is not re-applied after explicit opt-out',
        () async {
      final MemoryDevtoolStorage storage = MemoryDevtoolStorage();

      final Devtool first = Devtool(scope: DevtoolScope.enabled)
        ..register(_FakeCapability('a', enabledByDefault: true));
      await first.boot(DevtoolHost(storage: storage));
      expect(first.isEnabled('a'), isTrue);

      await first.setEnabled('a', false); // explicit opt-out

      final Devtool second = Devtool(scope: DevtoolScope.enabled)
        ..register(_FakeCapability('a', enabledByDefault: true));
      await second.boot(DevtoolHost(storage: storage));

      expect(second.isEnabled('a'), isFalse);
    });
  });
}

class _FakeCapability extends DevtoolCapability {
  _FakeCapability(
    this._id, {
    this.enabledByDefault = false,
    this.hotSwappable = true,
    this.throwOnEnable = false,
  });

  final String _id;

  @override
  final bool enabledByDefault;

  @override
  final bool hotSwappable;

  final bool throwOnEnable;

  int enableCount = 0;
  int disableCount = 0;

  @override
  String get id => _id;

  @override
  String get name => _id;

  @override
  Future<void> onEnable(DevtoolHost host) async {
    enableCount++;
    if (throwOnEnable) throw StateError('enable failed');
  }

  @override
  Future<void> onDisable(DevtoolHost host) async {
    disableCount++;
  }
}
