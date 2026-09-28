# weak-network Specification

## Purpose
TBD - created by archiving change weak-network. Update Purpose after archive.
## Requirements
### Requirement: Fixed delay
系统 SHALL 支持对所有请求注入固定延迟。

#### Scenario: Fixed delay applied
- **WHEN** 用户设置固定延迟 500ms 并开启弱网
- **THEN** 每个请求在发出前等待 500ms

### Requirement: Random jitter
系统 SHALL 支持在基础延迟上叠加随机抖动。

#### Scenario: Jitter applied
- **WHEN** 用户设置延迟 500ms、抖动 200ms
- **THEN** 实际延迟在 500~700ms 区间随机分布

### Requirement: Packet loss and random failure
系统 SHALL 支持按概率丢弃请求或使请求随机失败。

#### Scenario: Request dropped by probability
- **WHEN** 用户设置丢包率 20%
- **THEN** 约 20% 的请求被随机拒绝为失败

### Requirement: Timeout simulation
系统 SHALL 支持通过超长延迟触发请求超时。

#### Scenario: Timeout triggered
- **WHEN** 用户选择"请求超时"场景
- **THEN** 请求以超时错误失败

### Requirement: Temporary offline
系统 SHALL 支持一键临时断网，使所有请求立即失败。

#### Scenario: Offline mode
- **WHEN** 用户开启临时断网
- **THEN** 所有新请求立即失败，不等待超时

### Requirement: Preset scenarios
系统 SHALL 提供 2G、3G、弱 Wi-Fi 等预设场景。

#### Scenario: Preset applies parameters
- **WHEN** 用户选择 2G 预设
- **THEN** 延迟、丢包等参数按 2G 特征（约 50kbps / 500ms RTT）自动配置

### Requirement: Applies to all Dio instances
系统 SHALL 将弱网拦截器注入 `DevtoolHost` 提供的所有 Dio 实例。

#### Scenario: Multi-Dio coverage
- **WHEN** 宿主注入多个 Dio 实例
- **THEN** 弱网设置对全部实例生效

