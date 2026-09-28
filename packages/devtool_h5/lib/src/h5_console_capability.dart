import 'package:devtool_core/devtool.dart';

import 'h5_console_page.dart';

/// A [DevtoolCapability] providing an H5 portal and a restricted JS console.
///
/// This capability is a no-op on enable/disable — its page is reached through
/// the [DevtoolEntry]. It MUST only be registered in internal debug builds.
class H5ConsoleCapability extends DevtoolCapability {
  @override
  String get id => 'h5-console';

  @override
  String get name => 'H5 任意门';

  @override
  String get description => '打开任意 URL 并执行受限 JavaScript';

  @override
  bool get enabledByDefault => false;
}

/// Builds the [DevtoolEntry] for an [H5ConsoleCapability].
DevtoolEntry h5ConsoleEntry(H5ConsoleCapability capability) {
  return DevtoolEntry(
    id: capability.id,
    name: capability.name,
    group: 'UI 与 Web',
    pageBuilder: (context, host) => const H5ConsolePage(),
  );
}
