## Why

网络请求可视化是日常研发、测试与现场排查收益最高的能力。项目已用 Dio，可直接在拦截器链插桩，无需引入新网络库。

## What Changes

- 新增 `NetworkLogEntry` 不可变快照模型（方法、URL、状态码、耗时、Header/Body、失败原因、traceId）
- 新增 `NetworkLogInterceptor`，在 `onRequest` 记开始、`onResponse`/`onError` 记完成，用 `options.extra` 关联
- 复用有界 `RingBuffer` 与 `SensitiveDataMasker`，脱敏在写入时完成
- 支持复制 cURL、Trace ID 关联、状态/方法筛选、关键字搜索、清空
- 新增网络面板 UI（列表 + 详情）

## Capabilities

### New Capabilities
- `network-panel`: 网络请求捕获与可视化

### Modified Capabilities
- `devtool-core`: 复用其 `RingBuffer` / `SensitiveDataMasker` / `DevtoolEntry` 注册机制（无 spec 级行为变更）

## Impact

- **依赖**：dio（复用现有）、package:collection（若用 ListQueue）
- **顺序**：网络面板拦截器须排在业务拦截器之后、弱网拦截器之前（见 weak-network）
- **性能**：写入环形缓冲 + 脱敏开销须可忽略；stream 响应体仅记录大小或跳过
