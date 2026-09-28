## Why

调试工具需要一套微内核基础，使每个调试能力成为独立、可开关、可热插拔的插件；同时该内核必须为"公共包"而设计（去单例、支持多 Dio、存储可缺省、逻辑与 UI 分离），否则后续能力无法独立演进、也无法被多个项目复用。

## What Changes

- 新增 `Devtool` 类（构造函数注入、`register`/`boot`/`setEnabled`），替代硬编码单例
- 新增 `DevtoolCapability` 抽象（含 `hotSwappable` 标志与对称的 `onEnable`/`onDisable`）
- 新增 `DevtoolHost`（`List<Dio>`、`navigatorKey`、`DevtoolStorage`）
- 新增 `DevtoolStorage` 抽象 + `MemoryDevtoolStorage` / `PrefsDevtoolStorage` 两种实现
- 新增 `DevtoolEntry`（逻辑/UI 分离的注册点）
- 新增 `DevtoolScope` 枚举 + 编译期开关（`const bool.fromEnvironment`）
- 新增基础设施：有界 `RingBuffer<T>`、`SensitiveDataMasker`、`DevtoolShell` 调试中心 UI

## Capabilities

### New Capabilities
- `devtool-core`: 微内核与基础设施，是所有调试能力的宿主与契约

### Modified Capabilities
<!-- 无，全新项目 -->

## Impact

- **依赖**：新增 dio、shared_preferences（宽松版本区间）
- **契约**：`DevtoolCapability` 接口是后续所有能力的对外契约，需按语义化版本管理
- **发布**：`DevtoolScope.disabled` 时 `boot()` 必须为 no-op，Release 下实现被 tree-shaker 移除
