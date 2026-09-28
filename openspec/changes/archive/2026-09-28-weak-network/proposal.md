## Why

Snapmaker 涉及登录、模型下载、文件上传、MQTT 与局域网设备控制，弱网恢复能力是关键质量项。需在 App 内一键模拟弱网，验证超时重试与降级逻辑。

## What Changes

- 新增 `WeakNetworkController`（状态 + 预设场景，ChangeNotifier）
- 新增 `WeakNetworkInterceptor`：固定延迟、随机抖动、丢包/随机失败、超时、临时断网
- 限速首版用"按 body 字节数折算延迟"近似，不实现真带宽限流
- 遍历 `DevtoolHost` 所有 Dio 实例注入，置于拦截器链最外层
- 新增弱网 UI：预设（2G/3G/弱 Wi-Fi）+ 自定义滑块

## Capabilities

### New Capabilities
- `weak-network`: 弱网模拟

### Modified Capabilities
- `devtool-core`: 复用 `DevtoolHost.dioInstances` 遍历注入（无 spec 级行为变更）

## Impact

- **依赖**：dio（复用）
- **顺序**：弱网拦截器必须最外层，模拟整个链路而非单个业务拦截器之后
- **风险**：与网络面板拦截器顺序冲突，需文档固化
