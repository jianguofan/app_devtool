## Context

复用 Dio 拦截器链，无需新网络库。数据经有界环形缓冲供 UI 订阅。

## Goals / Non-Goals

**Goals:** 完整捕获进出数据、脱敏、cURL、traceId、筛选搜索。
**Non-Goals:** 不做真实弱网（见 weak-network）、不持久化到磁盘（有界内存即可）。

## Decisions

1. **拦截器关联**：`onRequest` 用 `options.extra` 写入唯一 id，`onResponse`/`onError` 用该 id 回填耗时与响应。理由：并发安全、零全局状态。
2. **stream 响应处理**：面板拦截器在 `onRequest` 将 `responseType` 临时改为 `json/plain`，stream 响应仅记录大小。理由：stream body 不可重复读，避免消费数据流。
3. **脱敏时机**：写入环形缓冲时脱敏，而非展示时。理由：导出/复制不会漏。
4. **拦截器顺序**：网络面板拦截器加在业务拦截器之后、弱网之前。理由：面板记录"业务视角"的请求，弱网在最外层模拟链路。

## Risks / Trade-offs

- [大 body 内存占用] → 超过阈值（如 64KB）截断并标记 truncated
- [FormData/文件 body 序列化] → 非文本 body 记录类型与大小，不展开二进制
- [拦截器异常影响正常链路] → 面板内部全 try/catch，绝不让调试代码干扰业务

## Migration Plan

无迁移。首个实现：`NetworkLogEntry` → `NetworkLogInterceptor` → 接入环形缓冲/脱敏 → UI。

## Open Questions

- 是否需要按请求域名过滤（避免内部上报流量刷屏）——首版先提供手动筛选。
