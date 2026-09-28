## Context

选用 `flutter_inappwebview`（功能强于 webview_flutter），拆独立包隔离重依赖。

## Goals / Non-Goals

**Goals:** 任意门、Header/UA/Cookie 管理、JS 执行、Bridge 日志、console 捕获。
**Non-Goals:** 不提供完整的浏览器开发者工具（Elements/Network 面板）。

## Decisions

1. **选型**：`flutter_inappwebview`。理由：`evaluateJavascript`、`addJavaScriptHandler`、`onConsoleMessage`、`CookieManager` 均内置。
2. **独立包 `devtool_h5`**：重依赖不进 `devtool_core`，宿主不用则不声明。
3. **JS 返回值回显**：对对象先 `JSON.stringify` 再回传，避免拿到 `[object Object]`。
4. **安全门**：任意 URL/JS 是命令注入入口，仅 `internal` 及更严格 scope 可用，README 顶部声明威胁模型。

## Risks / Trade-offs

- [任意 JS 执行被误用] → 编译期隔离 + 强警告 + 仅内部包
- [flutter_inappwebview 版本兼容] → 锁宽松区间并写兼容说明
- [evaluateJavascript 结果序列化失败] → try/catch 回显错误信息而非崩溃

## Migration Plan

无迁移。实现顺序：包骨架 → 任意门 → JS 控制台 → Bridge/console 日志 → 安全门。

## Open Questions

- 是否需要支持多 Tab、前进后退等浏览器导航能力。
