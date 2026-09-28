## Context

复用 Flutter 引擎公开的帧回调与进程内存接口，不引入 profiler 级重依赖。

## Goals / Non-Goals

**Goals:** FPS、慢帧、悬浮窗、启动耗时、内存采样。
**Non-Goals:** 完整 CPU profiler、函数级 flame graph（留给外部 DevTools/Profiler）。

## Decisions

1. **FPS 数据源**：`SchedulerBinding.instance.addTimingsCallback` + `FrameTiming.buildDuration/rasterDuration`。理由：官方、无新增依赖。
2. **悬浮窗注入**：用 `navigatorKey.currentState.overlay.insert(OverlayEntry)`，窗口 `IgnorePointer` 包裹可拖动层。理由：复用 App 已有 Overlay，不另造。
3. **启动埋点**：`main()` 入口打点 → `addPostFrameCallback` 首次触发记首帧 → 业务首页数据就绪记可交互。理由：跨平台无系统 API，用应用侧打点近似。
4. **debug 数据不可信**：明确标注，慢帧结论引导到 Profile。理由：JIT 放大帧耗时，避免误导测试。

## Risks / Trade-offs

- [悬浮窗生命周期与热关] → `onDisable` 对称 `overlay.remove()` + `removeTimingsCallback`
- [web 平台无 dart:io] → 内存项按平台条件隐藏
- [启动埋点依赖业务接入] → 提供轻量 `StartupMark` API，业务可选接入

## Migration Plan

无迁移。实现顺序：FpsMonitor → 悬浮窗 → 启动埋点 → 内存采样 → UI。

## Open Questions

- 是否需要 120Hz 设备的帧预算自适应（按 `MediaQuery` refreshRate 计算）。
