## 1. Dart 层探针

- [x] 1.1 Dart 未捕获异常探针（throw 于 runZoned 外）
- [x] 1.2 Flutter Framework 异常探针（build 阶段 throw）
- [x] 1.3 Isolate 异常探针（新 isolate 未捕获 throw）

## 2. 监控链路探针

- [x] 2.1 非致命错误探针（Sentry.captureException / Crashlytics.recordError）
- [x] 2.2 自定义事件/breadcrumb 探针（captureMessage / addBreadcrumb）
- [x] 2.3 监控环境与用户授权状态查看

## 3. 原生崩溃与 OOM（devtool_native）

- [x] 3.1 创建 `packages/devtool_native` 插件，注册 MethodChannel
- [x] 3.2 原生崩溃方法（Android 空指针/抛异常；iOS fatalError）
- [x] 3.3 OOM/内存压力探针（分档内存分配）

## 4. 警告 UI 与注册

- [x] 4.1 探针列表页，每项按钮 + 破坏性探针大红确认框
- [x] 4.2 编译期隔离：仅内部构建出现，Release 移除
- [x] 4.3 通过 `DevtoolEntry` 注册（group: 日志与稳定性）

## 5. 测试与验证

- [x] 5.1 单测：Dart/Flutter 探针触发对应 handler
- [x] 5.2 验证：手动触发各探针，确认 Sentry/Crashlytics 后台收到对应事件
- [x] 5.3 验证：Release 构建确认模块不存在
