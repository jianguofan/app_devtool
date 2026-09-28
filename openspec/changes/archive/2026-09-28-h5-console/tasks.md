## 1. 独立包

- [x] 1.1 创建 `packages/devtool_h5`，声明 flutter_inappwebview 依赖（宽松区间）
- [x] 1.2 注册到 `devtool` 聚合入口，作为可选能力

## 2. H5 任意门

- [x] 2.1 URL 输入 + `InAppWebView` 加载
- [x] 2.2 Header 注入（addHeader）
- [x] 2.3 User-Agent 查看与覆盖（applicationNameForUserAgent/customUserAgent）
- [x] 2.4 Cookie 查看与清除（CookieManager）

## 3. JS 控制台

- [x] 3.1 `evaluateJavascript` 执行 + JSON 序列化回显
- [x] 3.2 执行异常 try/catch 回显错误
- [x] 3.3 `addJavaScriptHandler` 记录 JS Bridge 调用（方法名 + 参数）
- [x] 3.4 `onConsoleMessage` 捕获 H5 console
- [x] 3.5 `onLoadError`/`onReceivedError` 捕获加载错误

## 4. 安全与注册

- [x] 4.1 scope 校验：仅 `internal` 及更严格可用，否则不注册
- [x] 4.2 Release 编译期移除（`const bool.fromEnvironment` + 不注册）
- [x] 4.3 README 顶部声明威胁模型与安全边界
- [x] 4.4 通过 `DevtoolEntry` 注册（group: UI 与 Web）

## 5. 测试与验证

- [x] 5.1 widget 测试：任意门加载（mock 控制器）
- [x] 5.2 单测：JS 结果序列化与异常回显
- [x] 5.3 验证：flutter analyze + flutter test 通过；Release 构建确认模块不存在
