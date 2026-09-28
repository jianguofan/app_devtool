## ADDED Requirements

### Requirement: Capability registration and boot
系统 SHALL 通过唯一 id 注册能力，并在 `boot()` 时仅初始化已启用的能力。

#### Scenario: Boot enables only enabled capabilities
- **WHEN** 宿主注册多个能力且仅部分被配置为启用，然后调用 `boot()`
- **THEN** 仅被启用的能力收到 `onEnable`，未启用的能力不初始化

### Requirement: Hot-swappable lifecycle
系统 SHALL 在开关切换时调用对称的 `onEnable`/`onDisable`，并用 `hotSwappable` 标注不可热切的能力。

#### Scenario: Toggle invokes lifecycle
- **WHEN** 用户开启一个能力
- **THEN** 系统调用其 `onEnable`；关闭时调用其 `onDisable`

#### Scenario: Non-hot-swappable capability
- **WHEN** 某能力声明 `hotSwappable == false`
- **THEN** 调试中心将其开关标记为"需重启生效"，且不调用运行时 `onDisable`

### Requirement: Host injection
系统 SHALL 通过 `DevtoolHost` 接收宿主的多个 Dio 实例、Navigator key 与存储实现，能力不得反向依赖宿主代码。

#### Scenario: Multiple Dio instances
- **WHEN** 宿主注入多个 Dio 实例
- **THEN** 网络类能力可遍历全部实例注入拦截器

### Requirement: Storage abstraction with fallback
系统 SHALL 通过 `DevtoolStorage` 持久化开关状态，未提供存储时回退到内存实现而不崩溃。

#### Scenario: Missing storage falls back
- **WHEN** 宿主未提供 `DevtoolStorage`
- **THEN** 系统使用内存实现，开关在会话内有效，且不抛异常

### Requirement: Scope gating
系统 SHALL 在 `DevtoolScope.disabled` 时使 `boot()` 成为 no-op，并在 Release 下通过编译期开关移除实现。

#### Scenario: Disabled scope is a no-op
- **WHEN** `Devtool` 以 `scope == disabled` 构造并调用 `boot()`
- **THEN** 不注册、不注入任何能力，`boot()` 立即返回

### Requirement: Logic/UI separation
系统 SHALL 将能力逻辑（`DevtoolCapability`）与其 UI（`DevtoolEntry`）分离，使内核可 headless 使用。

#### Scenario: Capability without UI
- **WHEN** 一个能力未注册对应 `DevtoolEntry`
- **THEN** 该能力逻辑仍可启用，仅在调试中心不显示入口

### Requirement: Failure isolation
系统 SHALL 隔离单个能力初始化失败，不影响其他能力的启用。

#### Scenario: One capability throws on enable
- **WHEN** 某能力 `onEnable` 抛出异常
- **THEN** 该异常被捕获记录，其余能力照常启用

### Requirement: Bounded ring buffer
系统 SHALL 提供容量固定的环形缓冲，写入超过容量时淘汰最旧元素，内存不随运行时间增长。

#### Scenario: Buffer evicts oldest
- **WHEN** 向容量为 N 的缓冲写入第 N+1 条记录
- **THEN** 最旧的一条被移除，缓冲大小保持为 N

### Requirement: Sensitive data masking
系统 SHALL 对 token、password、cookie、手机号等敏感字段进行统一脱敏，脱敏发生在写入而非展示时。

#### Scenario: Mask sensitive fields
- **WHEN** 一条记录包含 `Authorization`、`password`、`cookie`、手机号字段
- **THEN** 对应值被替换为 `***`，且导出文件同样被脱敏
