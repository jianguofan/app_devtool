## 1. SharedPreferences 查看器

- [x] 1.1 实现 key 列表读取（`getKeys`），含类型识别与搜索
- [x] 1.2 实现 value 展示（JSON 美化、普通文本、布尔/数字）
- [x] 1.3 实现编辑（setString/setInt/setBool）与删除（remove），均二次确认
- [x] 1.4 删除前记录原始值，支持撤销恢复
- [x] 1.5 接入 `SensitiveDataMasker` 脱敏 + 显式"查看原文"操作
- [x] 1.6 可选"原始文件"视图（读底层 xml/plist）

## 2. 沙盒浏览器

- [x] 2.1 基于 `path_provider` 枚举 Documents/Support/Temp 根目录
- [x] 2.2 文件列表：名称、大小、修改时间，递归但限制深度
- [x] 2.3 预览：文本/JSON、图片缩略、二进制十六进制头 + 大小
- [x] 2.4 路径白名单 + `path.isWithin` 逃逸校验
- [x] 2.5 文件导出（复制到临时目录 / share_plus 分享）

## 3. 安全与注册

- [x] 3.1 编译期移除：Release 下不注册路由、不编译实现
- [x] 3.2 通过 `DevtoolEntry` 注册（group: 数据工具）

## 4. 测试与验证

- [x] 4.1 单测：prefs 类型识别与编辑/删除
- [x] 4.2 单测：敏感字段脱敏
- [x] 4.3 单测：路径逃逸被拒绝
- [x] 4.4 单测：删除撤销恢复
- [x] 4.5 验证：flutter analyze + flutter test 通过；Release 构建确认模块不存在
