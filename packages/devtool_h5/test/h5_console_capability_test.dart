import 'package:devtool_core/devtool.dart';
import 'package:devtool_h5/devtool_h5.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('capability metadata and gating defaults', () {
    final H5ConsoleCapability capability = H5ConsoleCapability();
    expect(capability.id, 'h5-console');
    expect(capability.name, 'H5 任意门');
    expect(capability.enabledByDefault, isFalse);
    expect(capability.hotSwappable, isTrue);
  });

  test('entry wires the page into the UI & Web group', () {
    final DevtoolEntry entry = h5ConsoleEntry(H5ConsoleCapability());
    expect(entry.id, 'h5-console');
    expect(entry.group, 'UI 与 Web');
    expect(entry.pageBuilder, isNotNull);
  });
}
