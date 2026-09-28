import 'devtool_host.dart';

/// A single pluggable debug capability.
///
/// Implementations define *logic only*; their UI is registered separately via
/// [DevtoolEntry]. The kernel never depends on a concrete capability — it only
/// knows this abstraction.
abstract class DevtoolCapability {
  /// Unique identifier (kebab-case), e.g. `network-panel`.
  String get id;

  /// Human-readable display name.
  String get name;

  /// Short description shown in the debug center.
  String get description => '';

  /// Whether the capability is enabled on first run (only applied when no
  /// persisted record exists yet).
  bool get enabledByDefault => false;

  /// Whether the capability can be toggled at runtime. When `false`, changes
  /// take effect on the next [boot] and the shell marks it "需重启生效".
  bool get hotSwappable => true;

  /// Called when the capability is enabled. Must be reversible via [onDisable].
  Future<void> onEnable(DevtoolHost host) async {}

  /// Called when the capability is disabled. Must undo [onEnable].
  Future<void> onDisable(DevtoolHost host) async {}
}
