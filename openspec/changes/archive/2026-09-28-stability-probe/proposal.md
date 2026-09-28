## Why

需要主动触发各类崩溃/异常，验证 Sentry/Crashlytics 等监控链路的采集与上报是否正常。价值在于给监控链路做冒烟测试。

## What Changes

- 新增稳定性探针页，覆盖：Dart 未捕获异常、Flutter Framework 异常、Isolate 异常、原生崩溃、非致命错误、自定义事件/breadcrumb、OOM/内存压力
- 原生崩溃探针走 MethodChannel，独立 `devtool_native` 插件承载
- 所有破坏性探针显示清晰警告，且仅在内部调试构建出现

## Capabilities

### New Capabilities
- `stability-probe`: 稳定性验证探针

### Modified Capabilities
- `devtool-core`: 复用 scope 与注册机制（无 spec 级行为变更）

## Impact

- **依赖**：现有 Sentry/Crashlytics SDK；原生崩溃探针依赖 `devtool_native` MethodChannel
- **安全**：原生崩溃 + 内存压力探针属破坏性操作，必须强警告 + 内部包限定
