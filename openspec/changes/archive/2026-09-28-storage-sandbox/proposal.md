## Why

排查 Token、缓存、Feature Flag、文件下载与环境残留问题，需要直接查看本地存储与沙盒文件。实现成本低、收益高。

## What Changes

- 新增 SharedPreferences 查看器：列出 key/value（含类型）、搜索、编辑、删除（二次确认）、敏感字段脱敏
- 新增沙盒浏览器：基于 `path_provider` 列出 Documents/Support/Temp 目录，文件预览、导出
- 路径逃逸防护（目录白名单 + `path.isWithin` 校验）
- 仅 Debug/Profile 或内部签名包开放；Release 编译期移除

## Capabilities

### New Capabilities
- `storage-sandbox`: SharedPreferences 查看器与沙盒文件浏览器

### Modified Capabilities
- `devtool-core`: 复用 `DevtoolStorage`/`SensitiveDataMasker`（无 spec 级行为变更）

## Impact

- **依赖**：shared_preferences、path_provider、share_plus（导出，可拆包）
- **安全**：目录白名单、脱敏、写操作二次确认、编译期移除，四条必须同时满足
