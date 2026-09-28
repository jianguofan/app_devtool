## Context

在 Dio 拦截器层注入人为延迟/失败，是覆盖上层全部 HTTP 链路的最低成本方案。

## Goals / Non-Goals

**Goals:** 延迟、抖动、丢包、超时、断网、预设、多 Dio 覆盖。
**Non-Goals:** 真实带宽限流（TCP 层）、MQTT 弱网（超出 Dio 范围，另议）。

## Decisions

1. **拦截器层而非自定义 Adapter**：首版在 Interceptor 注入延迟/失败，限速用"字节数折算延迟"近似。理由：自定义 `HttpClientAdapter` 复杂度高、收益边际小，后续确有需要再演进。
2. **最外层注入**：弱网拦截器加在 Dio 拦截器链最前（最靠近 Dio 实例）。理由：模拟的是"整个链路"的弱网，而非业务拦截器之后。
3. **状态集中管理**：`WeakNetworkController`（ChangeNotifier）持有参数，拦截器只读、不持有 UI。

## Risks / Trade-offs

- [拦截器顺序与网络面板冲突] → 文档固化：弱网最外层 → 网络面板 → 业务
- [字节折算延迟非真限速] → UI 标注"近似"，真限速留给后续 Adapter 方案
- [弱网残留导致误判线上问题] → 开关状态持久化，UI 醒目提示"弱网已开启"

## Migration Plan

无迁移。实现顺序：Controller → Interceptor → 预设 → 多 Dio 注入 → UI。

## Open Questions

- MQTT/局域网链路是否需要同类弱网能力，是否复用同一套 controller。
