# MoonMark

高性能纯 MoonBit Markdown 解析与渲染引擎，支持 CommonMark 子集。

## 架构

本项目采用严格的多包架构（Workspaces）：
- `src/ast`: 跨包共享的语法树定义
- `src/parser`: 状态机驱动的扫描器和解析器
- `src/html`: 包含 XSS 防御的渲染器
- `src/cli`: 对外提供的终端使用工具

## 开发与贡献

执行 `make build` 编译，`make test` 运行单元测试。
