## 1. 包拆分

- [x] 1.1 建立 `devtool` 聚合入口（barrel，`export show` 收敛 API）
- [x] 1.2 将重依赖能力拆到 `devtool_h5`，原生能力拆到 `devtool_native`
- [x] 1.3 确认宿主不依赖某能力时其依赖不进解析结果

## 2. API 与文档

- [x] 2.1 每个公开符号 dartdoc，`dartdoc` 零 warning
- [x] 2.2 编写 `PLUGIN_AUTHORING.md`（如何实现/注册一个新能力）
- [x] 2.3 README：接入方式、安全边界、威胁模型、scope 说明

## 3. 示例与测试

- [x] 3.1 创建 `example/` 最小接入 demo
- [x] 3.2 补齐内核与各能力的单测/widget 测试
- [x] 3.3 测试覆盖 Release 编译期移除行为

## 4. CI 与质量门

- [x] 4.1 GitHub Actions：analyze + format + dartdoc + test
- [x] 4.2 失败阻断合并

## 5. 版本与分发

- [x] 5.1 语义化版本 + `CHANGELOG.md` + `LICENSE`
- [x] 5.2 私有 pub server（unpub/自建）或 monorepo path/git 依赖配置
- [x] 5.3 （若开源）`dart pub publish` + pub points 优化
- [x] 5.4 发布前安全审查：危险能力 gating、脱敏、编译期移除验证

## 6. 验证

- [x] 6.1 在真实宿主 App 集成验证依赖解析与 Release 裁剪
- [x] 6.2 记录最终分发路径与版本基线
