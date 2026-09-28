## Context

将已完成的各调试能力工程化为可复用包。核心是依赖隔离与对外契约管理。

## Goals / Non-Goals

**Goals:** 包拆分、API 收敛、文档、示例、测试、CI、版本、分发。
**Non-Goals:** 不改动各能力的 spec 级行为。

## Decisions

1. **包拆分**：`devtool_core`（内核+轻能力）、`devtool_ui`（默认 UI）、`devtool_h5`、`devtool_native`、`devtool`（聚合）。理由：让"不用就不进依赖树"成立。
2. **契约管理**：`DevtoolCapability` / `DevtoolHost` / `DevtoolStorage` / `DevtoolEntry` 为公开契约，语义化版本，接口变更走主版本。
3. **分发**：公司内共用优先私有 pub server（unpub 或自建）或 monorepo path/git 依赖；开源走 pub.dev（额外安全审查 + pub points）。

## Risks / Trade-offs

- [拆包增加维护成本] → 能力未超 8~10 个前先单包，超阈值再拆
- [依赖版本冲突] → 宽松区间 + 明确支持范围
- [公开包暴露内部地址/数据] → 危险能力拆包 + 脱敏 + 编译期移除三保险

## Migration Plan

从单包 `devtool_core` 起步，能力增多后按依赖边界拆分。发布前完成安全审查。

## Open Questions

- 是否开源（决定 LICENSE 与安全审查强度）；内部/开源需用户确认。
