# MoonMark - 高性能 MoonBit Markdown 解析与渲染引擎

[![MoonBit](https://img.shields.io/badge/MoonBit-0.10.3-orange.svg)](https://moonbitlang.com)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Build Status](https://github.com/zmjknn/zxnMoonbit/actions/workflows/ci.yml/badge.svg)](https://github.com/zmjknn/zxnMoonbit/actions)

MoonMark 是一款完全使用 [MoonBit](https://www.moonbitlang.com/) 编写的轻量级、极速 Markdown 解析器与 HTML 渲染引擎。对齐 **CommonMark 规范**，为博客系统（SSG）、在线预览工具以及富文本编辑器提供强大的基础设施支持。

[English Documentation](README.md) | [参考与致谢说明](REFERENCES.md)

---

## 🌟 核心特性与申报承诺实现

### 1. 🚀 零分配 (Zero-Allocation) 解析架构
- **内存视图设计**：AST 节点（`Text`, `CodeSpan`, `Link`, `Image`, `CodeBlock`）中存储的文本元数据全部采用 MoonBit 原生的 `StringView` 内存视图切片。
- **零堆分配保障**：在语法分析阶段，解析器无需为文本片段执行任何 `String` 堆内存分配与拷贝，实现极致解析性能（单次基准测试平均耗时低于 5 µs）。

### 2. 📍 精确 Span 位置追踪 (Precise Source Mapping)
- `Position` 结构同时记录 **1-based 行号 (line)**、**1-based 列号 (column)** 以及 **0-based 字符偏移量 (offset)**。
- 每一个 `Block` 和 `Inline` 语法树节点均包含精确的 `span : Span`（含 `start` 与 `end`），方便集成 IDE 语法高亮、错误诊断与代码重构工具。

### 3. 🛡️ 完整 XSS 安全防护 (Complete XSS Protection)
- **HTML 实体转义**：严格转义 `<` (`&lt;`), `>` (`&gt;`), `&` (`&amp;`), `"` (`&quot;`), `'` (`&#39;`) 等敏感字符。
- **URL 协议清洗 (`sanitize_url`)**：自动对 `Link` 与 `Image` 节点中的目标 URL 进行协议扫描与防护，全面中和 `javascript:`, `vbscript:`, `file:`, `data:text/html` 等 XSS 注入 payload，将其安全重定向至 `#`。

### 4. 📦 批量转换与强大的 CLI
- **开箱即用 CLI**：支持单文件转换、多文件批量转换（`--batch`）以及整目录递归转换（`--dir`）。
- **目录自动创建**：输出目标路径若不存在，命令行工具会自动调用操作系统 API 创建目录结构。

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

请确保安装了最新稳定版的 MoonBit 工具链（建议 v0.10.3 及以上）：
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

# 5. 接口签名校验
moon info
```

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
将输入目录下的所有 `.md` 文件批量渲染为 `.html` 并输出到目标文件夹：
```bash
moon run src/cli -- --dir docs/ -o dist/
```

### 5. 帮助菜单
```bash
moon run src/cli -- --help
```

---

## 📚 开源参考与致谢 (Prior Art & References)

本项目在架构设计与规格规范制定过程中参考了以下优秀开源项目：

1. **[marked.js](https://github.com/markedjs/marked)** (MIT License)
   - **参考范围**：AST 语法树节点分类划分（Block/Inline 拆分机制）、HTML 实体转义规则设计及 CLI 命令选项交互规范。
2. **[pulldown-cmark](https://github.com/pulldown-cmark/pulldown-cmark)** (MIT License)
   - **参考范围**：基于 `StringView` 切片的零分配状态机解析模型、事件驱动流式解析理念与 CommonMark 测试样例建设思路。

详细参考、许可证全文及引用范围声明请参见 [REFERENCES.md](REFERENCES.md)。

---

## 📄 许可证

本项目基于 [Apache License 2.0](LICENSE) 协议开源。
