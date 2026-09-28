## Context

每种异常/崩溃的捕获机制位于不同层，探针需逐层触发验证。

## Goals / Non-Goals

**Goals:** 覆盖 Dart / Flutter / Isolate / 原生 / 非致命 / 自定义事件 / OOM 七类探针。
**Non-Goals:** 不实现新的崩溃采集 SDK，只触发与验证既有链路。

## Decisions

1. **逐层触发**：Dart 异常走 `runZonedGuarded` 外的 throw；Flutter 异常在 build 阶段 throw；Isolate 在新 isolate 未捕获 throw；原生崩溃经 MethodChannel 调原生 crash 方法。
2. **原生崩溃探针放 `devtool_native`**：默认不携带主动崩溃代码，拆独立插件、显式 opt-in。
3. **破坏性探针强警告**：点击前弹大红确认，触发后引导去 Sentry/Crashlytics 后台核对。

## Risks / Trade-offs

- [原生崩溃代码进入公共包] → 拆 `devtool_native` 独立包，默认不装，README 声明
- [OOM 探针可能导致 App 被杀] → 强警告 + 分档内存分配，避免一次性崩死
- [误触发影响生产] → 编译期隔离，仅内部构建

## Migration Plan

无迁移。实现顺序：Dart/Flutter/Isolate 探针 → 非致命/自定义事件 → 原生崩溃（devtool_native）→ OOM → 警告 UI。

## Open Questions

- 是否需要自动断言"探针触发后监控后台在 N 秒内收到事件"。
