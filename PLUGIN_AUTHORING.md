# 编写一个新的调试能力（Capability）

调试工具采用微内核 + 能力插件架构：内核（`Devtool`）只认 `DevtoolCapability` 抽象，每个能力是一个独立、可开关、可热插拔的插件。

## 1. 实现能力逻辑

继承 `DevtoolCapability`，实现逻辑（不涉及 UI）：

```dart
import 'package:devtool_core/devtool.dart';

class MyCapability extends DevtoolCapability {
  @override
  String get id => 'my-capability';        // kebab-case，唯一

  @override
  String get name => '我的能力';

  @override
  bool get enabledByDefault => false;       // 首次运行是否默认开启

  @override
  bool get hotSwappable => true;            // false = 需重启生效

  @override
  Future<void> onEnable(DevtoolHost host) async {
    // 注入拦截器 / 注册回调。必须能被 onDisable 对称撤销。
  }

  @override
  Future<void> onDisable(DevtoolHost host) async {
    // 撤销 onEnable 的副作用。
  }
}
```

## 2. 实现 UI（可选）

UI 与逻辑分离，通过 `DevtoolEntry` 单独注册：

```dart
DevtoolEntry myEntry(MyCapability capability) {
  return DevtoolEntry(
    id: capability.id,
    name: capability.name,
    group: '性能检测',                     // 调试中心分组
    pageBuilder: (context, host) => MyPage(capability: capability),
  );
}
```

能力可以不注册 `DevtoolEntry` —— 它仍可启用，只是调试中心不显示入口（headless 使用）。

## 3. 在宿主中注册

```dart
final my = MyCapability();
devtool
  ..register(my)
  ..registerEntry(myEntry(my));
```

## 约定

- `onEnable` 必须可逆；不可逆的能力用 `hotSwappable = false` 标注。
- 生命周期回调内 try/catch，绝不因调试代码破坏业务。
- 敏感数据在写入时脱敏（`SensitiveDataMasker`）。
- 记录用有界缓存（`RingBuffer`），内存不随运行时间增长。
- 危险能力（任意 URL/JS/崩溃）拆独立包，仅内部构建 opt-in。
