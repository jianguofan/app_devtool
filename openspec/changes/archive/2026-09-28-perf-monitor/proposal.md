## Why

App 内实时性能诊断是当前与 DoKit 的主要差距之一。用 Flutter 公开能力（FrameTiming）实现轻量 FPS/卡顿/启动耗时，测试与现场人员无需连接开发机即可采集性能证据。

## What Changes

- 新增 `FpsMonitor`：基于 `addTimingsCallback` 计算 FPS、慢帧计数、最近慢帧列表（含当前路由）
- 新增悬浮 FPS 窗（经 `navigatorKey` 的 Overlay 插入/移除，可拖动）
- 新增启动耗时埋点：main 入口 → 首帧 → 首页可交互
- 新增内存采样：`ProcessInfo.currentRss` 定期采样
- UI 明确标注"debug 数据受 JIT 放大，结论以 Profile 为准"

## Capabilities

### New Capabilities
- `perf-monitor`: FPS / 卡顿 / 启动耗时 / 内存监控

### Modified Capabilities
- `devtool-core`: 复用 `DevtoolHost.navigatorKey` 注入悬浮窗（无 spec 级行为变更）

## Impact

- **依赖**：无新增（内置 `SchedulerBinding` / `dart:io`）
- **平台**：`ProcessInfo` 依赖 `dart:io`，web 平台不可用（需降级隐藏内存项）
- **准确性**：debug 模式帧数据被 JIT 放大，仅可相对比较
