## Context

直接读取平台存储与沙盒目录，核心难点是安全边界而非功能本身。

## Goals / Non-Goals

**Goals:** 查看/编辑 prefs、浏览/预览/导出沙盒文件。
**Non-Goals:** 不暴露 App 目录之外的系统文件；不做任意目录遍历。

## Decisions

1. **prefs 读取**：优先 `shared_preferences.getKeys()`；另提供"原始文件"视图读底层 xml/plist 看插件未暴露的键。
2. **路径白名单**：仅允许从 `path_provider` 拿到的根目录往下走，所有路径 `path.isWithin(root, target)` 校验后放行。
3. **安全四件套**：目录白名单 + 默认脱敏 + 写操作二次确认 + 编译期移除。理由：这些工具天然暴露 Token/用户数据，安全必须内建而非外挂。
4. **导出**：文本直接复制，文件经 `share_plus` 分享（可选拆包，避免核心包引入重依赖）。

## Risks / Trade-offs

- [误删关键存储导致环境损坏] → 二次确认 + 删除前记录原始值，支持恢复
- [share_plus 增加依赖] → 导出能力拆到 `devtool_export` 或标记可选依赖
- [目录遍历读到敏感文件] → 白名单 + 深度限制，禁止符号链接逃逸

## Migration Plan

无迁移。实现顺序：prefs 查看器 → 沙盒浏览器 → 安全校验 → 导出。

## Open Questions

- 是否需要对 prefs 修改做变更审计（记录谁在何时改了什么）。
