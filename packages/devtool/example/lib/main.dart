// 最小接入示例。完整的 Flutter App 脚手架请用 `flutter create` 生成后，
// 将本文件内容替换到 lib/main.dart。
import 'package:devtool/devtool.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final Dio dio = Dio();

  // 编译期开关：release 下整个 boot 分支被 tree-shaker 移除。
  if (kDevtoolEnabled) {
    final NetworkPanelCapability network = NetworkPanelCapability();
    final WeakNetworkCapability weakNetwork = WeakNetworkCapability();
    final PerfCapability perf = PerfCapability();

    final Devtool devtool = Devtool(scope: DevtoolScope.debugOnly)
      ..register(network)
      ..registerEntry(networkPanelEntry(network))
      ..register(weakNetwork)
      ..registerEntry(weakNetworkEntry(weakNetwork))
      ..register(perf)
      ..registerEntry(perfEntry(perf));

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
            builder: (BuildContext context) => FilledButton(
              onPressed: () {
                final Devtool? devtool = Devtool.instance;
                if (devtool == null) return;
                final List<DevtoolEntry> entries = devtool.entries;
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext _) => DevtoolShell(devtool: devtool, entries: entries),
                  ),
                );
              },
              child: const Text('打开调试中心'),
            ),
          ),
        ),
      ),
    );
  }
}
