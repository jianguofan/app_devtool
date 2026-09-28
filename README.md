# Snapmaker DevTool

面向 Snapmaker APP 的 **App 内调试工具包**（Flutter），对标 Bambu Handy 的 DoKit。核心目标是让测试、产品和现场人员**无需连接开发机**即可采集问题证据。

采用 **微内核 + 能力插件** 架构：内核只认 `DevtoolCapability` 抽象，每个调试能力是一个独立、可开关、可热插拔的插件。

## 架构

```
宿主 App ──注入──> Devtool（微内核）──注册/开关──> 各能力（插件）
                      │
                      ├── DevtoolHost   (多 Dio、navigatorKey、存储)
                      ├── DevtoolStorage (开关持久化，可内存兜底)
                      └── DevtoolScope   (编译期/运行时安全边界)
```

三级开关：

| 层级 | 机制 | 目的 |
|---|---|---|
| 编译期 | `const bool.fromEnvironment('DEVTOOL_ENABLED')` + tree-shaking | Release 彻底移除实现 |
| 运行时 | `DevtoolConfig` 持久化 + `onEnable`/`onDisable` | 按需注入/摘除 |
| 入口 | 隐藏手势 / 菜单 / debug-only 按钮 | 普通用户不可见 |

## 包结构

| 包 | 内容 | 说明 |
|---|---|---|
| `packages/devtool_core` | 微内核 + 网络/弱网/性能/存储/稳定性 5 个能力 | 安全，无重依赖 |
| `packages/devtool_h5` | H5 任意门 + 受限 JS 控制台 | **危险**（任意 JS），仅内部构建 opt-in |
| `packages/devtool_native` | 原生崩溃探针（Android/iOS） | **危险**，仅内部构建 opt-in |
| `packages/devtool` | 聚合入口 | 只含 `devtool_core`，危险能力需显式依赖 |
| `example/` | 可运行 demo | 接入示例 + 真机验证 |

## 能力清单

- **network-panel** —— HTTP 请求可视化（方法/状态码/耗时/Header/Body、脱敏、复制 cURL、Trace ID、筛选搜索）
- **weak-network** —— 弱网模拟（延迟/抖动/丢包/超时/断网/预设 2G·3G·弱Wi-Fi）
- **perf-monitor** —— FPS/慢帧/可拖动悬浮窗/启动耗时/内存曲线（refreshRate 自适应）
- **storage-sandbox** —— SharedPreferences 查看器（编辑/撤销/脱敏/原始数据） + 沙盒浏览器（预览/hex/导出/路径守卫）
- **stability-probe** —— 稳定性探针（Dart/Flutter/Isolate/原生崩溃/非致命/OOM 分档）
- **h5-console** —— H5 任意门（Header/UA/Cookie）+ 受限 JS 控制台

## 快速开始

```bash
# 运行 demo（web）
cd example && flutter run -d chrome

# 或连真机
cd example && flutter run

# 跑测试（全包）
for p in devtool_core devtool_h5 devtool_native devtool; do
  (cd packages/$p && flutter test)
done
```

最小接入：

```dart
if (kDevtoolEnabled) {
  final network = NetworkPanelCapability();
  final devtool = Devtool(scope: DevtoolScope.debugOnly)
    ..register(network)
    ..registerEntry(networkPanelEntry(network));
  await devtool.boot(DevtoolHost(
    dioInstances: [dio],
    navigatorKey: navigatorKey,
    storage: PrefsDevtoolStorage(prefs),
  ));
}
```

## 安全边界

1. Release 不显示入口，`const bool.fromEnvironment` 编译期移除实现（已实证：web/AOT 产物中 devtool 符号为 0）。
2. 日志、网络 Body、本地存储统一脱敏（写入时）。
3. 任意 URL/JS/数据编辑/崩溃探针仅内部包（`devtool_h5`/`devtool_native` opt-in）。
4. 调试记录有界缓存，内存不随运行时间增长。

## 扩展新能力

见 [`PLUGIN_AUTHORING.md`](PLUGIN_AUTHORING.md)。

## 开发流程（OpenSpec）

本项目用 [OpenSpec](https://github.com/Fission-AI/OpenSpec) 做 spec-driven 开发：

```bash
openspec list                    # 查看变更
openspec spec list               # 查看 spec
/opsx:propose "新能力描述"        # 新建变更
/opsx:apply <change>             # 实现
/opsx:archive <change>           # 归档
```

- `openspec/specs/` —— 8 份能力 spec（source of truth）
- `openspec/changes/archive/` —— 已完成 change 的历史

## License

MIT（见 [LICENSE](LICENSE)）
