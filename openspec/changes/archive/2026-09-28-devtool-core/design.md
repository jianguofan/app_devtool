## Context

全新 Flutter 调试工具包，无既有代码。需在一开始就满足"公共包"约束，避免后续重构。

## Goals / Non-Goals

**Goals:**
- 可实例化、可测试、支持多 Dio、存储可缺省、逻辑/UI 分离
- 编译期可整体裁剪（Release 无调试实现）

**Non-Goals:**
- 不在内核实现任何具体调试能力
- 不引入重依赖（flutter_inappwebview 等留到 `devtool_h5` 拆包）

## Decisions

1. **去单例**：`Devtool` 用构造函数实例化，另设可选 `Devtool.instance` 由宿主显式赋值，包内部一律不引用全局。理由：可多实例、可测试、避免宿主间状态污染。
2. **存储抽象**：`DevtoolStorage` 接口 + 内存/prefs 两实现。理由：shared_preferences 不能成为硬依赖，缺失时兜底。
3. **逻辑/UI 分离**：`DevtoolCapability`（逻辑）与 `DevtoolEntry`（UI）分开注册。理由：第三方可用逻辑自建 UI，内核可 headless。
4. **scope + 编译期开关**：`DevtoolScope.disabled` 使 `boot()` no-op；`const bool.fromEnvironment('DEVTOOL_ENABLED')` 包住注册代码，Release 下 tree-shaker 移除实现。理由：安全边界与包体积。
5. **失败隔离**：`boot`/`setEnabled` 对每个能力的生命周期调用 try/catch。理由：一个能力崩不应拖垮整个工具。

## Risks / Trade-offs

- [多个能力共享 Dio 拦截器顺序冲突] → 约定拦截器插入顺序，弱网在最外层、网络面板次之，文档固化
- [tree-shaking 只裁编译产物、不裁 pubspec 依赖图] → 重依赖能力拆独立包，宿主不用则不声明依赖
- [hotSwappable=false 的能力无法运行时热关] → UI 明确标注"需重启生效"，避免误导

## Migration Plan

全新项目，无迁移。首个实现顺序：`DevtoolScope` → `DevtoolCapability` → `Devtool`/`DevtoolHost` → `DevtoolStorage` → 基础设施 → `DevtoolShell`。

## Open Questions

- 是否需要支持远程下发开关（Release 下按用户灰度开启某项诊断）——涉及安全决策，暂缓。
