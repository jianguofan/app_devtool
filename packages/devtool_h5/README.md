# devtool_h5

H5 任意门 + 受限 JavaScript 控制台，基于 `flutter_inappwebview`。

## ⚠️ 威胁模型

任意 URL 加载 + 任意 JavaScript 执行 = **命令注入入口**。本包仅允许在内部调试构建中使用：

1. 不要将本包加入 Release 依赖树（`devtool` 聚合包默认**不**包含本包）。
2. 宿主仅在内部 flavor 下注册 `H5ConsoleCapability`。
3. Release 构建通过编译期开关彻底移除入口与实现。

## 能力

- 打开任意 URL（可注入 Header）
- 查看/覆盖 User-Agent
- 查看/清除 Cookie
- 执行 JavaScript 并回显结果
- 记录 JS Bridge 调用（`window.flutter_inappwebview.callHandler`）
- 捕获 H5 console 输出与加载错误

## 接入

```dart
import 'package:devtool_h5/devtool_h5.dart';

// 仅内部构建：
devtool
  ..register(H5ConsoleCapability())
  ..registerEntry(h5ConsoleEntry(H5ConsoleCapability()));
```
