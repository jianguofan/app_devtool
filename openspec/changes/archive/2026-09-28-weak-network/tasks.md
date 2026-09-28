## 1. 控制器

- [x] 1.1 实现 `WeakNetworkController`（ChangeNotifier）：enabled、delayMs、jitterMs、lossRate、timeoutRate、offline
- [x] 1.2 定义预设场景（2G / 3G / 弱 Wi-Fi）的参数映射
- [x] 1.3 开关状态接入 `DevtoolStorage` 持久化

## 2. 拦截器

- [x] 2.1 实现 `WeakNetworkInterceptor.onRequest`：读 controller 状态，应用延迟/抖动/丢包/断网
- [x] 2.2 实现 `onResponse` 延迟（模拟下行）
- [x] 2.3 超时场景：延迟超过 connect/receiveTimeout 触发超时
- [x] 2.4 临时断网：onRequest 立即 reject，不等超时
- [x] 2.5 限速近似：按响应 body 字节数折算延迟

## 3. 注入与生命周期

- [x] 3.1 `onEnable`：遍历 `DevtoolHost.dioInstances`，将拦截器插入最外层
- [x] 3.2 `onDisable`：从所有 Dio 实例移除拦截器
- [x] 3.3 与网络面板顺序固化：弱网最外层 → 网络面板 → 业务

## 4. UI

- [x] 4.1 预设场景选择 + 自定义参数滑块
- [x] 4.2 醒目的"弱网已开启"状态提示
- [x] 4.3 通过 `DevtoolEntry` 注册（group: 网络工具）

## 5. 测试与验证

- [x] 5.1 单测：固定延迟生效
- [x] 5.2 单测：抖动在区间内随机
- [x] 5.3 单测：丢包按概率失败
- [x] 5.4 单测：断网立即失败
- [x] 5.5 单测：多 Dio 注入与移除
- [x] 5.6 验证：flutter analyze + flutter test 通过
