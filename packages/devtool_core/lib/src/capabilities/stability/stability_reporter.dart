/// Describes the monitoring environment and user authorization state.
class MonitoringInfo {
  const MonitoringInfo({
    this.provider,
    this.environment,
    this.userConsent,
    this.isEnabled = false,
  });

  /// Monitoring backend, e.g. `Sentry` / `Crashlytics`.
  final String? provider;

  /// Current environment, e.g. `debug` / `staging` / `production`.
  final String? environment;

  /// Whether the user consented to data collection (null = unknown).
  final bool? userConsent;

  /// Whether monitoring is currently active.
  final bool isEnabled;
}

/// Reports non-fatal errors and custom events to the host's monitoring backend
/// (e.g. Sentry / Crashlytics). The host supplies the implementation.
abstract class StabilityReporter {
  void captureException(Object error, StackTrace stackTrace);

  void captureMessage(String message);

  void addBreadcrumb(String message);

  /// Monitoring environment and authorization state.
  MonitoringInfo get info => const MonitoringInfo();
}
