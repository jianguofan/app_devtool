## 1. 数据模型

- [x] 1.1 定义 `NetworkLogEntry` 不可变模型（id、method、url、statusCode、startAt、duration、requestHeaders、requestBody、responseHeaders、responseBody、error、traceId、truncated）
- [x] 1.2 定义 `NetworkLogStore`（ChangeNotifier），内部持有 `RingBuffer<NetworkLogEntry>`，提供 begin/complete/clear 接口

## 2. 拦截器

- [x] 2.1 实现 `NetworkLogInterceptor.onRequest`：记开始时间、method/url/请求 Header/Body，`options.extra` 写 id，必要时改 `responseType`
- [x] 2.2 实现 `onResponse`：回填 statusCode/duration/响应 Header/Body，提取 trace-id
- [x] 2.3 实现 `onError`：回填失败原因与耗时
- [x] 2.4 大 body 截断（阈值 + truncated 标记）；FormData/二进制记录类型与大小
- [x] 2.5 拦截器内部全 try/catch，异常不干扰业务链路

## 3. 脱敏与导出

- [x] 3.1 接入 `SensitiveDataMasker`，写入 `NetworkLogStore` 前脱敏
- [x] 3.2 实现 cURL 反拼装
- [x] 3.3 trace-id 提取与展示

## 4. UI

- [x] 4.1 列表页：方法/状态码着色、耗时、URL、失败标记
- [x] 4.2 详情页：请求/响应 Header、Body（JSON 美化、文本、二进制摘要）
- [x] 4.3 筛选：按方法、状态码、成功/失败；搜索：URL/关键字
- [x] 4.4 操作：复制 cURL、复制 body、清空记录
- [x] 4.5 通过 `DevtoolEntry` 注册到调试中心（group: 网络工具）

## 5. 测试与验证

- [x] 5.1 单测：成功/失败请求均产生正确记录
- [x] 5.2 单测：并发请求通过 extra id 正确关联
- [x] 5.3 单测：环形缓冲溢出淘汰最旧
- [x] 5.4 单测：脱敏在存储前完成，导出内容不含原文
- [x] 5.5 单测：cURL 输出与请求一致
- [x] 5.6 验证：flutter analyze + flutter test 通过
