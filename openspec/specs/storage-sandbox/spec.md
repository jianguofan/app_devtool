# storage-sandbox Specification

## Purpose
TBD - created by archiving change storage-sandbox. Update Purpose after archive.
## Requirements
### Requirement: List SharedPreferences entries
系统 SHALL 列出所有 SharedPreferences 键、值及其类型。

#### Scenario: Entries listed
- **WHEN** 用户打开 SharedPreferences 查看器
- **THEN** 显示全部键、对应值、类型与脱敏后的敏感字段

### Requirement: Edit and delete with confirmation
系统 SHALL 支持编辑/删除 SharedPreferences 条目，且写操作需二次确认。

#### Scenario: Delete requires confirmation
- **WHEN** 用户删除一个键
- **THEN** 系统弹出确认框，确认后才执行删除

### Requirement: Sensitive masking
系统 SHALL 对 token、cookie、手机号等敏感键值默认脱敏。

#### Scenario: Sensitive value masked
- **WHEN** 键名或值匹配敏感字段
- **THEN** 展示为 `***`，需显式操作才可查看原文

### Requirement: Sandbox directory browsing
系统 SHALL 列出 Documents / Support / Temp 目录下的文件（名称、大小、修改时间）。

#### Scenario: Files listed
- **WHEN** 用户进入沙盒浏览器
- **THEN** 显示目录内容与文件元信息

### Requirement: Path traversal protection
系统 SHALL 限制可访问目录范围，阻止路径逃逸（如 `../`）。

#### Scenario: Escape rejected
- **WHEN** 目标路径解析后越出允许的根目录
- **THEN** 系统拒绝访问并提示

### Requirement: File preview and export
系统 SHALL 支持文本/JSON 预览、图片缩略、二进制十六进制头，以及文件导出。

#### Scenario: Text file previewed
- **WHEN** 用户点击一个文本文件
- **THEN** 显示其内容；二进制文件显示大小与十六进制头

### Requirement: Release gating
系统 SHALL 仅在 Debug/Profile 或内部签名包开放，Release 通过编译条件移除入口与实现。

#### Scenario: Release excluded
- **WHEN** 构建 Release 包
- **THEN** 存储与沙盒模块的入口与实现均不存在

