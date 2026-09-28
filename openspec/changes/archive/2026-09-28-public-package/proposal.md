## Why

将调试工具从"单项目内部工具"提升为可复用的公共/共享包，需要完成包拆分、公开 API 收敛、文档、示例、测试、CI、版本管理与分发。

## What Changes

- 拆分为 `devtool_core` / `devtool_ui` / `devtool_h5` / `devtool_native` / `devtool`（聚合入口）
- 公开 API 收敛（barrel + `export show`，内部符号私有）
- dartdoc + 插件编写指南（`PLUGIN_AUTHORING.md`）
- example 示例应用、测试补齐、CI（analyze/format/dartdoc/test）
- 语义化版本 + CHANGELOG + LICENSE
- 分发策略（私有 pub server 或 pub.dev）

## Capabilities

### New Capabilities
- `public-package`: 包工程化、发布与分发

### Modified Capabilities
<!-- 无 spec 级行为变更，仅工程化 -->

## Impact

- **契约**：`DevtoolCapability` 接口成为对外契约，按语义化版本管理
- **安全**：危险能力（H5 任意门、原生崩溃）拆独立包默认不装，README 声明威胁模型
- **分发**：确定私有 pub server 或 pub.dev 路径，影响依赖解析与发布流程
