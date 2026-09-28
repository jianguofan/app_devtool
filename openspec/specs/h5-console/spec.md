# h5-console Specification

## Purpose
TBD - created by archiving change h5-console. Update Purpose after archive.
## Requirements
### Requirement: Open arbitrary URL with headers
系统 SHALL 允许输入 URL 并注入自定义 Header 后加载。

#### Scenario: Open URL with header
- **WHEN** 用户输入 URL 与 Header 并打开
- **THEN** WebView 加载该 URL 并携带指定 Header

### Requirement: User-Agent view and override
系统 SHALL 支持查看与覆盖 User-Agent。

#### Scenario: Override User-Agent
- **WHEN** 用户设置自定义 User-Agent
- **THEN** 后续请求使用该 User-Agent

### Requirement: Cookie view and clear
系统 SHALL 支持查看与清除 WebView Cookie。

#### Scenario: Clear cookies
- **WHEN** 用户执行清除 Cookie
- **THEN** 相关 Cookie 被移除

### Requirement: JavaScript execution with echo
系统 SHALL 支持执行 JavaScript 并回显返回值。

#### Scenario: Execute and echo result
- **WHEN** 用户输入一段 JS 并执行
- **THEN** 显示执行结果（对象序列化为 JSON）

### Requirement: JS Bridge logging
系统 SHALL 记录 H5 通过 JS Bridge 调用的方法与参数。

#### Scenario: Bridge call logged
- **WHEN** H5 调用 `callHandler(name, args)`
- **THEN** 控制台记录方法名与参数

### Requirement: Console and load error capture
系统 SHALL 捕获 H5 的 console 输出与页面加载错误。

#### Scenario: Console captured
- **WHEN** H5 执行 `console.log`
- **THEN** 该输出出现在控制台；加载失败时记录错误

### Requirement: Internal-only gating
系统 SHALL 仅在内部调试构建可用，Release 不编译该模块。

#### Scenario: Release excluded
- **WHEN** 构建 Release 包
- **THEN** H5 调试模块不存在，任意脚本执行入口被移除

