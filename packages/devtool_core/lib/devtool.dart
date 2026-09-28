/// Public entry point for `devtool_core`.
///
/// Exposes only the stable surface: the microkernel ([Devtool]), its
/// abstractions ([DevtoolCapability], [DevtoolHost], [DevtoolStorage],
/// [DevtoolEntry]), shared infrastructure ([RingBuffer], [SensitiveDataMasker])
/// and the default shell ([DevtoolShell]). Internal symbols stay private.
library;

export 'src/capabilities/network/network_log_entry.dart' show NetworkLogEntry;
export 'src/capabilities/network/network_log_interceptor.dart'
    show NetworkLogInterceptor;
export 'src/capabilities/network/network_log_store.dart' show NetworkLogStore;
export 'src/capabilities/network/network_panel_capability.dart'
    show NetworkPanelCapability, networkPanelEntry;
export 'src/capabilities/network/network_panel_page.dart' show NetworkPanelPage;
export 'src/capabilities/weak_network/weak_network_capability.dart'
    show WeakNetworkCapability, weakNetworkEntry;
export 'src/capabilities/weak_network/weak_network_controller.dart'
    show WeakNetworkController, WeakNetworkProfile;
export 'src/capabilities/weak_network/weak_network_interceptor.dart'
    show WeakNetworkInterceptor;
export 'src/capabilities/weak_network/weak_network_page.dart' show WeakNetworkPage;
export 'src/capabilities/perf/fps_monitor.dart' show FpsMonitor, SlowFrame;
export 'src/capabilities/perf/memory_monitor.dart' show MemoryMonitor, MemorySample;
export 'src/capabilities/perf/perf_capability.dart' show PerfCapability, FloatingFps, perfEntry;
export 'src/capabilities/perf/perf_page.dart' show PerfPage;
export 'src/capabilities/perf/startup_mark.dart' show StartupMark;
export 'src/capabilities/storage/path_guard.dart' show PathGuard;
export 'src/capabilities/storage/prefs_viewer.dart' show PrefEntry, SharedPreferencesViewer;
export 'src/capabilities/storage/sandbox_browser.dart' show SandboxBrowser, SandboxEntry;
export 'src/capabilities/storage/storage_capability.dart'
    show StorageSandboxCapability, storageEntry;
export 'src/capabilities/storage/storage_page.dart' show StoragePage;
export 'src/capabilities/stability/stability_probe_capability.dart'
    show StabilityProbeCapability, stabilityEntry;
export 'src/capabilities/stability/stability_reporter.dart' show StabilityReporter, MonitoringInfo;
export 'src/capabilities/stability/stability_page.dart' show StabilityPage;
export 'src/core/devtool.dart' show Devtool, kDevtoolEnabled;
export 'src/core/devtool_capability.dart' show DevtoolCapability;
export 'src/core/devtool_entry.dart'
    show DevtoolEntry, DevtoolPageBuilder, DevtoolSettingsTileBuilder;
export 'src/core/devtool_host.dart' show DevtoolHost;
export 'src/core/devtool_scope.dart' show DevtoolScope;
export 'src/infra/ring_buffer.dart' show RingBuffer;
export 'src/infra/sensitive_data_masker.dart' show SensitiveDataMasker;
export 'src/storage/devtool_config.dart' show DevtoolConfig;
export 'src/storage/devtool_storage.dart' show DevtoolStorage;
export 'src/storage/memory_devtool_storage.dart' show MemoryDevtoolStorage;
export 'src/storage/prefs_devtool_storage.dart' show PrefsDevtoolStorage;
export 'src/ui/devtool_shell.dart' show DevtoolShell;
