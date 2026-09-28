# devtool

App 内调试工具包（Flutter），微内核 + 能力插件架构。

## 包结构

| 包 | 内容 | 说明 |
|---|---|---|
| `devtool_core` | 微内核 + 网络/弱网/性能/存储/稳定性能力 | 安全，无重依赖 |
| `devtool_h5` | H5 任意门 + JS 控制台 | **危险**（任意 JS 执行），仅内部构建，opt-in |
| `devtool_native` | 原生崩溃探针 MethodChannel | **危险**，仅内部构建，opt-in |
| `devtool` | 聚合入口 | 只含 `devtool_core`，危险能力需显式依赖 |

## 接入

```dart
import 'package:devtool/devtool.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final dio = Dio();

  // 编译期开关：release 下整个 boot 被 tree-shaker 移除。
  if (kDevtoolEnabled) {
    final devtool = Devtool(scope: DevtoolScope.debugOnly)
      ..register(NetworkPanelCapability())
      ..register(WeakNetworkCapability())
      ..register(PerfCapability())
      ..register(StorageSandboxCapability())
      ..register(StabilityProbeCapability());
    await devtool.boot(DevtoolHost(
      dioInstances: [dio],
      navigatorKey: navigatorKey,
      storage: PrefsDevtoolStorage(prefs),
    ));
  }

  runApp(const App());
}
```

## 安全边界

1. Release 不显示入口，并通过 `const bool.fromEnvironment('DEVTOOL_ENABLED')` 编译期移除实现。
2. 日志、网络 Body、本地存储统一脱敏（写入时）。
3. 任意 URL/JS/数据编辑/崩溃探针仅内部包使用（`devtool_h5` / `devtool_native` opt-in）。
4. 调试记录有界缓存，内存不随运行时间增长。

## 扩展

见 [`PLUGIN_AUTHORING.md`](../../PLUGIN_AUTHORING.md)。
