## 1. 包结构搭建

- [x] 1.1 创建 `packages/devtool_core` 包骨架（pubspec.yaml，`sdk: flutter`，依赖 dio/shared_preferences 用宽松版本区间）
- [x] 1.2 建立 `lib/devtool.dart` barrel 入口，用 `export ... show` 收敛公开 API
- [x] 1.3 配置 `analysis_options.yaml`（flutter_lints + 严格规则）

## 2. 微内核核心抽象

- [x] 2.1 实现 `DevtoolScope` 枚举（`disabled` / `debugOnly` / `internal` / `enabled`）
- [x] 2.2 实现 `Devtool` 类：构造函数注入 scope，`register` / `boot` / `setEnabled` / `isEnabled`，附可选 `static Devtool? instance`
- [x] 2.3 实现 `DevtoolCapability` 抽象（`id` / `name` / `hotSwappable` / `onEnable` / `onDisable`）
- [x] 2.4 实现 `DevtoolHost`（`List<Dio> dioInstances`、`navigatorKey`、`DevtoolStorage? storage`）
- [x] 2.5 实现 `DevtoolEntry`（`id` / `name` / `group` / `pageBuilder` / `settingsTile`）完成逻辑/UI 分离

## 3. 存储抽象

- [x] 3.1 定义 `DevtoolStorage` 接口（`getKeys` / `getString` / `setString`）
- [x] 3.2 实现 `MemoryDevtoolStorage`（内存兜底）
- [x] 3.3 实现 `PrefsDevtoolStorage`（基于 shared_preferences）
- [x] 3.4 实现 `DevtoolConfig`：开关持久化 + 首次运行默认值语义（仅在无持久化记录时应用 `enabledByDefault`）

## 4. 生命周期与编译期开关

- [x] 4.1 `boot()`：读配置 → 对已启用能力逐个 `onEnable`，每个调用 try/catch 隔离
- [x] 4.2 `setEnabled(id, on)`：`hotSwappable` 能力即时 `onEnable`/`onDisable`，否则标记"需重启"
- [x] 4.3 编译期开关：`const bool.fromEnvironment('DEVTOOL_ENABLED')`，`scope == disabled` 时 `boot()` 直接 return

## 5. 基础设施

- [x] 5.1 实现有界 `RingBuffer<T>`（容量固定、覆盖最旧）
- [x] 5.2 实现 `SensitiveDataMasker`（字段名 + 值正则，脱敏 token/password/cookie/手机号）
- [x] 5.3 实现 `DevtoolShell`（调试中心 UI，按 `group` 分组渲染各 `DevtoolEntry` 的开关与入口）

## 6. 测试与验证

- [x] 6.1 单测：注册 + `boot` 仅启用 enabled 能力
- [x] 6.2 单测：`setEnabled` 触发 `onEnable`/`onDisable`
- [x] 6.3 单测：能力 `onEnable` 抛异常不影响其他能力
- [x] 6.4 单测：`RingBuffer` 有界淘汰
- [x] 6.5 单测：`SensitiveDataMasker` 各类敏感字段脱敏
- [x] 6.6 单测：`DevtoolConfig` 首次运行默认值 + 持久化往返
- [x] 6.7 验证：`flutter analyze` + `dart format` + `flutter test` 全部通过
