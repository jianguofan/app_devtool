import 'package:devtool/devtool.dart';
import 'package:devtool_h5/devtool_h5.dart';
import 'package:devtool_native/devtool_native.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 编译期开关：release 下 kDevtoolEnabled == false，整个 devtool 注册与实现
  // 被 tree-shaker 从产物中移除。
  if (kDevtoolEnabled) {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Dio dio = Dio();

    final NetworkPanelCapability network = NetworkPanelCapability();
    final WeakNetworkCapability weakNetwork = WeakNetworkCapability();
    final PerfCapability perf = PerfCapability();
    final StorageSandboxCapability storage = StorageSandboxCapability();
    final StabilityProbeCapability stability = StabilityProbeCapability(
      nativeCrash: const NativeCrashChannel().crash,
    );
    final H5ConsoleCapability h5 = H5ConsoleCapability();

    final Devtool devtool = Devtool(scope: DevtoolScope.debugOnly)
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
      navigatorKey: navigatorKey,
      storage: PrefsDevtoolStorage(prefs),
    ));

    Devtool.instance = devtool;
  }

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'devtool example',
      home: Scaffold(
        appBar: AppBar(title: const Text('devtool example')),
        body: Center(
          child: Builder(
            builder: (BuildContext context) {
              return FilledButton(
                onPressed: () {
                  // 仅在 debug（kDevtoolEnabled）下打开调试中心。
                  if (kDevtoolEnabled) {
                    final Devtool? devtool = Devtool.instance;
                    if (devtool != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext _) => DevtoolShell(
                            devtool: devtool,
                            entries: devtool.entries,
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('打开调试中心'),
              );
            },
          ),
        ),
      ),
    );
  }
}
