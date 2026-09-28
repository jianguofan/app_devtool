import '../../core/devtool_capability.dart';
import '../../core/devtool_entry.dart';
import 'storage_page.dart';

/// A [DevtoolCapability] for viewing SharedPreferences and the sandbox.
class StorageSandboxCapability extends DevtoolCapability {
  @override
  String get id => 'storage-sandbox';

  @override
  String get name => '数据工具';

  @override
  String get description => 'SharedPreferences 查看器与沙盒浏览器';

  @override
  bool get enabledByDefault => false;

  // Lifecycle is a no-op: the page reads prefs and the sandbox lazily.
}

/// Builds the [DevtoolEntry] for a [StorageSandboxCapability].
DevtoolEntry storageEntry(StorageSandboxCapability capability) {
  return DevtoolEntry(
    id: capability.id,
    name: capability.name,
    group: '数据工具',
    pageBuilder: (context, host) => const StoragePage(),
  );
}
