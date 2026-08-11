# MoonMark - 高性能 MoonBit Markdown 解析与渲染引擎

[![MoonBit](https://img.shields.io/badge/MoonBit-compatible-orange.svg)](https://www.moonbitlang.com/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Build Status](https://github.com/zmjknn/zxnMoonbit/actions/workflows/ci.yml/badge.svg)](https://github.com/zmjknn/zxnMoonbit/actions)

MoonMark 是一款完全使用 [MoonBit](https://www.moonbitlang.com/) 编写的轻量级 Markdown 解析器与 HTML 渲染引擎。本项目面向一个有明确文档边界的 **CommonMark 风格子集**，为博客系统（SSG）、在线预览工具以及富文本编辑器提供基础设施支持。

[English Documentation](README.md) | [参考与致谢说明](REFERENCES.md)

---

## 🌟 核心特性与申报承诺实现

### 1. 🚀 基于 StringView 的解析架构
- **内存视图设计**：AST 节点（`Text`、`CodeSpan`、`Link`、`Image`、`CodeBlock`）在能够保留源文本切片时使用 MoonBit 原生 `StringView`。
- **以实测为准**：扁平的块级/行级解析会避免复制文本片段；blockquote/list 等嵌套结构在规范化输入时可能创建临时缓冲区，基准结果取决于工具链和机器。

### 2. 📍 精确 Span 位置追踪 (Precise Source Mapping)
- `Position` 结构同时记录 **1-based 行号 (line)**、**1-based 列号 (column)** 以及基于当前解析器字符串索引模型的 **0-based 偏移量 (offset)**；列号不是 Unicode 字素簇计数。
- 每一个 `Block` 和 `Inline` 语法树节点均包含精确的 `span : Span`（含 `start` 与 `end`），方便集成 IDE 语法高亮、错误诊断与代码重构工具。

### 3. 🛡️ 防御式 HTML 渲染
- **HTML 实体转义**：严格转义 `<` (`&lt;`), `>` (`&gt;`), `&` (`&amp;`), `"` (`&quot;`), `'` (`&#39;`) 等敏感字符。
- **URL 协议清洗 (`sanitize_url`)**：扫描 `Link` 与 `Image` 目标协议，拒绝 `javascript:`、`vbscript:`、`file:` 及不安全的 `data:` 内容，并在写入属性前转义安全值。这是渲染器的防御层，不能替代 Content Security Policy。

### 4. 📦 批量转换与强大的 CLI
- **开箱即用 CLI**：支持单文件转换、多文件批量转换（`--batch`）以及递归目录转换（`--dir`），并保留相对目录结构。
- **目录自动创建**：输出目标路径若不存在，命令行工具会自动调用操作系统 API 创建目录结构。

## 功能范围与当前边界

- 当前版本支持标题、段落、引用、围栏代码块、有序/无序列表、强调、加粗、行内代码、链接和图片。
- 原始 HTML 会作为文本转义输出。本项目不宣称完整 CommonMark 兼容、不提供原始 HTML 透传，也不承诺扩展语法兼容。
- URL 清洗是渲染器防御层；应用仍应自行校验不可信输入，并配置合适的 Content Security Policy（CSP）。
- `--dir` 会递归处理 `.md` 与 `.markdown`，保留相对目录并输出 `.html`；其他扩展名会被忽略。

---

## 🏗️ 架构概览

```text
moonmark/
├── src/ast/       # 抽象语法树（AST）核心定义，采用 StringView 与 Span 定义节点
├── src/parser/    # 状态机驱动的扫描器（Lexer）与向下递归解析器（Parser）
├── src/html/      # 安全转义工具及安全 URL 清洗 HTML 渲染映射
├── src/cli/       # 提供单文件、多文件与目录批量转换 CLI
└── benches/       # 性能基准测试模块
```

---

## 🛠️ 安装、构建与复现步骤

### 1. 安装 MoonBit 工具链

请安装与本模块兼容的稳定版 MoonBit 工具链，并先检查版本：
```bash
# 检查 MoonBit 版本
moon version
```

### 2. 获取代码与检验

```bash
git clone https://github.com/zmjknn/zxnMoonbit.git
cd zxnMoonbit

# 1. 语法检查
moon check --deny-warn

# 2. 单元测试
moon test

# 3. 性能基准测试
moon bench

# 4. 代码格式化校验
moon fmt --check

# 5. 重新生成公共接口文件（提交前请审阅生成差异）
moon info

# 6. CLI 冒烟测试
moon run src/cli -- --help

# 7. 检查补丁格式
git diff --check
```

`moon info` 的作用是重新生成公共 `.mbti` 接口文件，本身不是通过/失败式测试；提交前应审阅生成差异。

如果系统安装了 GNU Make，也可以使用 `make check`、`make fmt-check`、`make test`、`make bench` 和 `make cli-smoke` 快捷执行对应检查。

---

## 💻 CLI 命令行工具使用指南

### 1. Demo 演示模式
直接运行 CLI 查看默认演示效果：
```bash
moon run src/cli
```

### 2. 单文件转换模式
```bash
moon run src/cli -- input.md -o output.html
```

### 3. 多文件批量转换模式 (`--batch` / `-b`)
```bash
moon run src/cli -- --batch README.md README_zh.md -o dist/
```

### 4. 目录批量转换模式 (`--dir` / `-d`)
将输入目录及其子目录中的所有 `.md`、`.markdown` 文件批量渲染为 `.html`，并保留相对目录结构输出到目标文件夹：
```bash
moon run src/cli -- --dir docs/ -o dist/
# docs/guide/start.md -> dist/guide/start.html
```

### 5. 帮助菜单
```bash
moon run src/cli -- --help
```

`--dir` 会自动创建缺失的输出目录、保留嵌套相对路径，并忽略非 `.md`/`.markdown` 文件。读写失败会由 CLI 报错；如需机器可读的失败处理，请由调用方检查进程输出和目标文件。

---

## 本版本验证快照

当前仓库包含 15 个 `.mbt` 源码/测试文件和 12 个自动化测试，覆盖 AST Span、嵌套块重建、HTML 转义、危险 URL 协议、安全栅格图片 `data:` URL、空输入、Unicode 文本和 CLI 相对目录输出。

基准模块 `benches/bench.mbt` 包含三个命名工作负载。使用 `moon 0.1.20260713` 在 Windows 上得到的一组本地基线如下：

| 工作负载 | 平均值 ± σ | 范围 | 基准运行次数 |
| --- | ---: | ---: | ---: |
| 扁平 Markdown | 2.19 µs ± 132.08 ns | 2.04–2.42 µs | 10 × 49,233 |
| 结构化 Markdown | 3.01 µs ± 125.75 ns | 2.87–3.20 µs | 10 × 33,538 |
| Unicode 与嵌套 Markdown | 6.77 µs ± 167.50 ns | 6.57–7.09 µs | 10 × 14,904 |

以上数据是可复现的本地基线，不是跨机器性能保证；进行性能比较前请在目标工具链和硬件上重新运行 `moon bench`。

---

## 📚 开源参考与致谢 (Prior Art & References)

本项目在架构设计与规格规范制定过程中参考了以下优秀开源项目：

1. **[marked.js](https://github.com/markedjs/marked)** (MIT License)
   - **参考范围**：AST 语法树节点分类划分（Block/Inline 拆分机制）、HTML 实体转义规则设计及 CLI 命令选项交互规范。
2. **[pulldown-cmark](https://github.com/pulldown-cmark/pulldown-cmark)** (MIT License)
   - **参考范围**：基于 `StringView` 切片的零分配状态机解析模型、事件驱动流式解析理念与 CommonMark 测试样例建设思路。

详细参考、许可证全文及引用范围声明请参见 [REFERENCES.md](REFERENCES.md)。

本项目未打包或复制上述项目的源代码；`REFERENCES.md` 仅说明设计参考和许可证边界。MoonMark 自有源代码使用 Apache-2.0 发布。

---

## 📄 许可证

本项目基于 [Apache License 2.0](LICENSE) 协议开源。

Copyright 2026 zmjknn。各源文件也带有 Apache-2.0 版权头；`.mbti` 文件由 MoonBit 工具链生成。
