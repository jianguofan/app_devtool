import 'package:flutter/widgets.dart';

import 'devtool_host.dart';

/// Builds the main page for a capability.
typedef DevtoolPageBuilder = Widget Function(
    BuildContext context, DevtoolHost host);

/// Builds an optional custom settings tile for a capability.
typedef DevtoolSettingsTileBuilder = Widget Function(BuildContext context);

/// The UI registration point for a capability, decoupled from its logic.
///
/// A capability can be enabled with no corresponding [DevtoolEntry]; it simply
/// has no visible entry in the debug center.
class DevtoolEntry {
  const DevtoolEntry({
    required this.id,
    required this.name,
    required this.group,
    this.pageBuilder,
    this.settingsTile,
  });

  /// Matches the [DevtoolCapability.id] this entry represents.
  final String id;

  final String name;

  /// Debug-center group, e.g. `网络工具`, `性能检测`.
  final String group;

  final DevtoolPageBuilder? pageBuilder;

  final DevtoolSettingsTileBuilder? settingsTile;
}
