import 'package:devtool_core/devtool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('capability metadata', () {
    final StabilityProbeCapability capability = StabilityProbeCapability();
    expect(capability.id, 'stability-probe');
    expect(capability.enabledByDefault, isFalse);
  });

  test('non-fatal and custom events route through the reporter', () {
    final _MockReporter reporter = _MockReporter();
    final StabilityProbeCapability capability = StabilityProbeCapability(reporter: reporter);

    capability.captureNonFatal();
    capability.captureCustomEvent();

    expect(reporter.calls, contains('exception'));
    expect(reporter.calls, contains('message'));
    expect(reporter.calls, contains('breadcrumb'));
  });

  test('native crash without a handler throws', () async {
    final StabilityProbeCapability capability = StabilityProbeCapability();
    await expectLater(capability.triggerNativeCrash(), throwsStateError);
  });

  test('monitoring info defaults when no reporter', () {
    final StabilityProbeCapability capability = StabilityProbeCapability();
    expect(capability.info.isEnabled, isFalse);
    expect(capability.info.provider, isNull);
  });

  test('monitoring info comes from reporter', () {
    final _MockReporter reporter = _MockReporter(
      info: const MonitoringInfo(provider: 'Sentry', environment: 'staging', userConsent: true, isEnabled: true),
    );
    final StabilityProbeCapability capability = StabilityProbeCapability(reporter: reporter);

    expect(capability.info.provider, 'Sentry');
    expect(capability.info.environment, 'staging');
    expect(capability.info.userConsent, isTrue);
    expect(capability.info.isEnabled, isTrue);
  });
}

class _MockReporter implements StabilityReporter {
  _MockReporter({this.info = const MonitoringInfo()});

  final List<String> calls = <String>[];

  @override
  final MonitoringInfo info;

  @override
  void captureException(Object error, StackTrace stackTrace) => calls.add('exception');

  @override
  void captureMessage(String message) => calls.add('message');

  @override
  void addBreadcrumb(String message) => calls.add('breadcrumb');
}
