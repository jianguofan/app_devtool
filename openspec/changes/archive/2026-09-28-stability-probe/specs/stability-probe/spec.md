## ADDED Requirements

### Requirement: Dart exception probe
系统 SHALL 提供一个触发 Dart 未捕获异常的探针，以验证 `runZonedGuarded`/`PlatformDispatcher.onError` 链路。

#### Scenario: Dart exception triggered
- **WHEN** 用户执行 Dart 异常探针
- **THEN** 抛出未捕获异常，监控后台可收到对应事件

### Requirement: Flutter framework exception probe
系统 SHALL 提供一个触发 Flutter Framework 异常的探针，以验证 `FlutterError.onError` 链路。

#### Scenario: Framework exception triggered
- **WHEN** 用户执行 Flutter 异常探针
- **THEN** 在 build 阶段抛出异常，`FlutterError.onError` 捕获

### Requirement: Isolate exception probe
系统 SHALL 提供一个在新 Isolate 触发未捕获异常的探针。

#### Scenario: Isolate exception triggered
- **WHEN** 用户执行 Isolate 探针
- **THEN** 新 Isolate 抛出未捕获异常，监控后台可收到

### Requirement: Native crash probe
系统 SHALL 提供一个触发原生崩溃的探针（经 MethodChannel）。

#### Scenario: Native crash triggered
- **WHEN** 用户执行原生崩溃探针
- **THEN** 原生层触发崩溃，Crashlytics 捕获

### Requirement: Non-fatal and custom event probe
系统 SHALL 提供触发非致命错误上报与自定义事件/breadcrumb 的探针。

#### Scenario: Non-fatal captured
- **WHEN** 用户执行非致命错误探针
- **THEN** 调用 `captureException`/`captureMessage` 上报，后台可见

### Requirement: OOM pressure probe
系统 SHALL 提供内存压力测试探针。

#### Scenario: Memory pressure triggered
- **WHEN** 用户执行 OOM 探针
- **THEN** 分配大量内存以验证内存监控与 OOM 上报

### Requirement: Warning and internal-only gating
系统 SHALL 为每个破坏性探针显示清晰警告，且仅在内部调试构建出现。

#### Scenario: Warning shown before destructive probe
- **WHEN** 用户点击破坏性探针
- **THEN** 显示警告确认；Release 构建中该模块不存在
