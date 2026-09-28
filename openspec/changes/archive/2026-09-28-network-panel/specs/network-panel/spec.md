## ADDED Requirements

### Requirement: Capture request and response
系统 SHALL 记录每个 HTTP 请求的方法、URL、状态码、耗时、请求/响应 Header 与 Body。

#### Scenario: Successful request captured
- **WHEN** 应用发出一个 HTTP 请求并收到响应
- **THEN** 网络面板新增一条记录，包含方法、URL、状态码、耗时、Header 与 Body

### Requirement: Capture failure reason
系统 SHALL 在请求失败时记录失败原因。

#### Scenario: Failed request captured
- **WHEN** 一个请求因超时或网络错误失败
- **THEN** 记录中保存错误类型与信息，状态码为空

### Requirement: Bounded in-memory storage
系统 SHALL 将网络记录写入有界环形缓冲，超出容量淘汰最旧记录。

#### Scenario: Buffer overflow evicts oldest
- **WHEN** 记录数超过缓冲容量
- **THEN** 最旧的记录被移除，内存占用保持有界

### Requirement: Sensitive data masking
系统 SHALL 在记录写入时对 Header/Body 中的敏感字段（token、password、cookie、手机号）脱敏。

#### Scenario: Masked before storage
- **WHEN** 请求/响应含 `Authorization`、`password`、`cookie` 或手机号字段
- **THEN** 对应值以 `***` 存储，导出与详情展示均不可见原文

### Requirement: Copy as cURL
系统 SHALL 允许用户将一条记录复制为等价的 cURL 命令。

#### Scenario: Copy cURL
- **WHEN** 用户对一条记录执行"复制 cURL"
- **THEN** 剪贴板得到包含方法、URL、Header 与 Body 的完整 cURL 文本

### Requirement: Trace ID association
系统 SHALL 从响应 Header 提取 trace-id/request-id 并保存，以便与结构化日志关联。

#### Scenario: Trace ID extracted
- **WHEN** 响应 Header 含 `x-request-id` 或 `trace-id`
- **THEN** 该值保存到记录中并可在详情查看

### Requirement: Filter and search
系统 SHALL 支持按 HTTP 方法、状态码筛选，以及按 URL/关键字搜索。

#### Scenario: Filter by status
- **WHEN** 用户选择"仅失败请求"或指定状态码区间
- **THEN** 列表仅展示匹配的记录
