# Snapmaker DevTool

## Purpose

一个可复用的 Flutter 调试工具包，为 Snapmaker APP 提供 App 内调试能力（网络面板、弱网模拟、性能监控、本地数据浏览、H5 调试、稳定性探针等），对标 Bambu Handy 的 DoKit。核心目标是让测试、产品和现场人员**无需连接开发机**即可采集问题证据。

## Architecture

- **微内核 + 能力插件**：内核只认 `DevtoolCapability` 抽象，每个调试能力是一个独立、可开关、可热插拔的插件。
- **宿主注入**：宿主 App 通过 `DevtoolHost` 把 Dio 实例、Navigator、存储等对象句柄注入内核，插件不反向依赖宿主代码。
- **三级开关**：编译期（scope + tree-shaking）/ 运行时（persisted toggle）/ 入口（调试中心可见性）。

## Tech Stack

- Flutter / Dart（无原生代码的能力为纯 Flutter 包，崩溃探针、CPU 读取等走 MethodChannel 插件）
- 依赖：dio、shared_preferences、path_provider、flutter_inappwebview（仅 H5 能力，需拆包隔离）、share_plus（导出）

## Conventions

- 包命名：`devtool_core` / `devtool_ui` / `devtool_h5` / `devtool_native` / `devtool`（聚合入口）
- 能力命名：kebab-case，如 `network-panel`、`weak-network`、`perf-monitor`
- 安全红线：任意 URL/JS/数据编辑/崩溃探针仅限内部调试构建；Release 通过 `const bool.fromEnvironment` + tree-shaking 移除实现
- 每个能力 `onEnable` 必须可逆（对称的 `onDisable`），不可逆能力用 `hotSwappable=false` 标注"需重启生效"

## Domain Concepts

- **DevtoolScope**：disabled / debugOnly / internal / enabled，决定调试工具的可用边界
- **DevtoolStorage**：开关持久化抽象，默认 shared_preferences，可回退内存实现
- **DevtoolEntry**：能力 UI 的注册点，与逻辑解耦，按 group 分组呈现在调试中心
