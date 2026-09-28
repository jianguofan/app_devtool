# public-package Specification

## Purpose
TBD - created by archiving change public-package. Update Purpose after archive.
## Requirements
### Requirement: Package split
系统 SHALL 将重依赖与原生能力拆为独立包，使宿主不用的能力不进依赖树。

#### Scenario: Opt-in heavy dependency
- **WHEN** 宿主不依赖 `devtool_h5`
- **THEN** `flutter_inappwebview` 不进入其依赖解析

### Requirement: Public API convergence
系统 SHALL 通过 barrel + `export show` 只暴露稳定公开 API，内部符号私有。

#### Scenario: Internal symbols hidden
- **WHEN** 消费者导入包的公开入口
- **THEN** 无法引用内部实现符号

### Requirement: Documentation and authoring guide
系统 SHALL 为每个公开符号提供 dartdoc，并提供插件编写指南。

#### Scenario: Authoring guide available
- **WHEN** 开发者需要实现新能力
- **THEN** 依据 `PLUGIN_AUTHORING.md` 完成实现与注册

### Requirement: Example and tests
系统 SHALL 提供 example 示例应用与覆盖核心逻辑的测试。

#### Scenario: Example runnable
- **WHEN** 消费者运行 example
- **THEN** 可看到各调试能力的接入演示

### Requirement: CI quality gate
系统 SHALL 通过 CI 执行 analyze、format、dartdoc、test。

#### Scenario: CI gate
- **WHEN** 提交变更
- **THEN** CI 运行质量检查并在失败时阻断

### Requirement: Versioning and changelog
系统 SHALL 采用语义化版本并维护 CHANGELOG 与 LICENSE。

#### Scenario: Breaking change versioned
- **WHEN** `DevtoolCapability` 接口发生不兼容变更
- **THEN** 主版本号递增并在 CHANGELOG 记录

### Requirement: Dangerous capability gating
系统 SHALL 将 H5 任意门与原生崩溃探针拆为默认不安装的独立包，并在文档声明威胁模型。

#### Scenario: Dangerous capability opt-in
- **WHEN** 消费者默认安装聚合包
- **THEN** 危险能力不随包带入，需显式声明

