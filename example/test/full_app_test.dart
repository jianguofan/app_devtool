import 'package:devtool/devtool.dart';
import 'package:devtool_h5/devtool_h5.dart';
import 'package:devtool_native/devtool_native.dart';
import 'package:dio/dio.dart';
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('demo wires every capability and opens the debug center', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Dio dio = Dio();

    // Same wiring as lib/main.dart (minus the navigator-key overlay host).
    final NetworkPanelCapability network = NetworkPanelCapability();
    final WeakNetworkCapability weakNetwork = WeakNetworkCapability();
    final PerfCapability perf = PerfCapability();
    final StorageSandboxCapability storage = StorageSandboxCapability();
    final StabilityProbeCapability stability = StabilityProbeCapability(
      nativeCrash: const NativeCrashChannel().crash,
    );
    final H5ConsoleCapability h5 = H5ConsoleCapability();

    final Devtool devtool = Devtool(scope: DevtoolScope.enabled)
      ..register(network)
      ..registerEntry(networkPanelEntry(network))
      ..register(weakNetwork)
      ..registerEntry(weakNetworkEntry(weakNetwork))
      ..register(perf)
      ..registerEntry(perfEntry(perf))
      ..register(storage)
      ..registerEntry(storageEntry(storage))
      ..register(stability)
      ..registerEntry(stabilityEntry(stability))
      ..register(h5)
      ..registerEntry(h5ConsoleEntry(h5));

    await devtool.boot(DevtoolHost(
      dioInstances: <Dio>[dio],
      storage: PrefsDevtoolStorage(prefs),
    ));
    Devtool.instance = devtool;

    // Stop the perf memory timer before the test's pending-timer check.
    addTearDown(() => devtool.setEnabled('perf-monitor', false));

    await tester.pumpWidget(const ExampleApp());
    await tester.pump();

    expect(find.text('打开调试中心'), findsOneWidget);

    await tester.tap(find.text('打开调试中心'));
    await tester.pumpAndSettle();

    // Capability entries are grouped in the debug center.
    expect(find.text('网络请求'), findsOneWidget);
    expect(find.text('模拟弱网'), findsOneWidget);
    expect(find.text('稳定性探针'), findsOneWidget);
    expect(find.text('H5 任意门'), findsOneWidget);
  });
}
