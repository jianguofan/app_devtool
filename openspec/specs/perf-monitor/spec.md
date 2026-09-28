# perf-monitor Specification

## Purpose
TBD - created by archiving change perf-monitor. Update Purpose after archive.
## Requirements
### Requirement: FPS sampling
系统 SHALL 基于帧回调统计实时 FPS。

#### Scenario: FPS computed per interval
- **WHEN** 性能监控开启
- **THEN** 每秒统计一次 FPS 并展示在悬浮窗

### Requirement: Slow frame detection
系统 SHALL 将超过帧预算（60Hz 下 16.67ms）的帧记为慢帧，并记录 build/raster 耗时与当前路由。

#### Scenario: Jank recorded with route
- **WHEN** 某帧 build 或 raster 耗时超过 16.67ms
- **THEN** 系统记录该慢帧的耗时与发生时的路由名

### Requirement: Floating FPS window
系统 SHALL 提供可拖动、不阻塞交互的悬浮 FPS 窗。

#### Scenario: Overlay non-blocking
- **WHEN** 悬浮窗显示
- **THEN** 它不拦截触摸事件，且可被拖动定位

### Requirement: Startup timing
系统 SHALL 记录启动关键节点耗时：main 入口、首帧、首页可交互。

#### Scenario: Startup milestones captured
- **WHEN** 应用启动
- **THEN** 系统记录各关键节点时间戳并计算区间耗时

### Requirement: Memory sampling
系统 SHALL 定期采样进程 RSS 内存并展示曲线。

#### Scenario: Memory sampled
- **WHEN** 性能监控开启
- **THEN** 系统按固定间隔采样 `ProcessInfo.currentRss`

### Requirement: Accuracy disclaimer
系统 SHALL 在 UI 上标注 debug 模式数据受 JIT 影响，结论以 Profile 模式为准。

#### Scenario: Disclaimer visible
- **WHEN** 用户在 debug 模式查看性能页
- **THEN** 页面显示明确的准确性提示

