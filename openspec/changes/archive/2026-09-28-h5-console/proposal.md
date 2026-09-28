## Why

项目已有 WebView 基础，补一个 H5 任意门与受限 JS 控制台，可快速定位 H5 页面加载、JS Bridge 与 Cookie 问题。该能力依赖重依赖 `flutter_inappwebview`，需拆独立包，且必须严格限制在内部调试构建。

## What Changes

- 新增 `devtool_h5` 独立包（隔离 `flutter_inappwebview` 重依赖）
- H5 任意门：输入 URL、注入 Header、查看/覆盖 User-Agent、Cookie 查看与清除
- 受限 JS 控制台：`evaluateJavascript` 执行并回显、`addJavaScriptHandler` 记录 JS Bridge 调用、`onConsoleMessage` 捕获 H5 console、加载错误捕获
- 严格安全门：仅 `DevtoolScope.internal` 或更低构建可用，Release 不编译

## Capabilities

### New Capabilities
- `h5-console`: H5 任意门与受限 JavaScript 控制台

### Modified Capabilities
- `devtool-core`: 引入 `devtool_h5` 独立包的依赖隔离约定（无 spec 级行为变更）

## Impact

- **依赖**：flutter_inappwebview（仅 `devtool_h5` 包声明）
- **安全**：任意 URL/JS 执行 = 潜在命令注入入口，必须编译期隔离 + 强警告
