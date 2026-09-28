## 1. FPS 与慢帧

- [x] 1.1 实现 `FpsMonitor`：`addTimingsCallback` 采集，每秒统计 FPS
- [x] 1.2 实现慢帧检测（阈值按 refreshRate 自适应），记录 build/raster 耗时
- [x] 1.3 慢帧记录当前路由（经 `DevtoolHost` 提供 route 解析）
- [x] 1.4 最近慢帧列表（有界）

## 2. 悬浮窗

- [x] 2.1 实现悬浮 FPS 窗 Widget（IgnorePointer + 可拖动）
- [x] 2.2 `onEnable`：经 `navigatorKey.currentState.overlay` 插入 OverlayEntry
- [x] 2.3 `onDisable`：`overlay.remove()` + `removeTimingsCallback`

## 3. 启动耗时

- [x] 3.1 提供 `StartupMark` API（打点 + 区间计算）
- [x] 3.2 埋点：main 入口 / 首帧（addPostFrameCallback）/ 首页可交互
- [x] 3.3 启动耗时报告展示

## 4. 内存采样

- [x] 4.1 实现 `ProcessInfo.currentRss` 定期采样器
- [x] 4.2 内存曲线展示（有界）
- [x] 4.3 web 平台隐藏内存项

## 5. UI 与注册

- [x] 5.1 性能页：FPS、慢帧列表、启动耗时、内存曲线
- [x] 5.2 debug 准确性提示文案
- [x] 5.3 通过 `DevtoolEntry` 注册（group: 性能检测）

## 6. 测试与验证

- [x] 6.1 单测：FPS 统计逻辑（注入模拟 FrameTiming）
- [x] 6.2 单测：慢帧阈值判断与有界列表
- [x] 6.3 单测：StartupMark 区间计算
- [x] 6.4 验证：flutter analyze + flutter test 通过
