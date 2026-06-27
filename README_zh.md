# MoonMark - 高性能 MoonBit Markdown 解析与渲染引擎

[![MoonBit](https://img.shields.io/badge/MoonBit-0.1.0-orange.svg)](https://moonbitlang.com)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Build Status](https://github.com/zmjknn/zxnMoonbit/actions/workflows/ci.yml/badge.svg)](https://github.com/zmjknn/zxnMoonbit/actions)

MoonMark 是一款完全使用 [MoonBit](https://www.moonbitlang.com/) 纯手工打造的、轻量级且极速的 Markdown 解析器与 HTML 渲染引擎。它致力于对齐 **CommonMark 规范**，为 MoonBit 开发者在构建静态博客系统（SSG）、在线文档预览工具、以及富文本编辑器后端时，提供坚实的基础设施支撑。

## 🌟 核心特性

- **🚀 极致性能**：得益于 MoonBit 优秀的编译优化和基于状态机的零分配（Zero-allocation）解析架构，MoonMark 能够在极低内存占用的情况下实现极速解析。
- **🛡️ 安全可靠**：内置完整的 HTML 转义与 XSS 防御机制，确保用户输入的不可信 Markdown 文本也能被安全渲染。
- **🧩 强扩展性 AST**：解析过程会生成带有精确行列号（Span）的抽象语法树（AST），开发者可以基于此非常容易地开发自定义 Lint 工具或语法糖扩展（例如支持 GFM 表格、任务列表等）。
- **📦 模块化设计**：采用标准的 MoonBit 多包架构（Workspaces），将词法分析（Lexer）、语法分析（Parser）、渲染（Renderer）完全解耦。

## 🏗️ 架构概览

本项目采用典型的企业级开源架构设计：

```text
moonmark/
├── src/ast/       # 抽象语法树（AST）核心定义，定义了 Block 和 Inline 节点。
├── src/parser/    # 状态机驱动的扫描器（Lexer）与向下递归解析器（Parser）。
├── src/html/      # 安全转义工具及 HTML 渲染映射逻辑。
├── src/cli/       # 提供开箱即用的命令行工具代码。
└── benches/       # 性能基准测试模块。
```

## 🚀 快速开始

### 1. 作为依赖引入

在您的 `moon.pkg.json` 中引入 MoonMark：
```json
{
  "import": [
    "zmjknn/moonmark/src/parser",
    "zmjknn/moonmark/src/html"
  ]
}
```

### 2. 基础使用示例

```moonbit
pub fn main() {
  let markdown_text = 
    "# 欢迎使用 MoonMark\n\n这是一个**纯 MoonBit** 编写的解析器！"
  
  // 1. 初始化解析器并生成 AST
  let p = @parser.Parser::new(markdown_text)
  let ast_document = p.parse()
  
  // 2. 渲染为安全 HTML
  let html_output = @html.Renderer::new().render(ast_document)
  
  println(html_output)
}
```

## 📜 进度与 Roadmap

- [x] 核心解析架构搭建
- [x] 多级标题 (Headings) 支持
- [x] 段落与基础排版 (Paragraphs) 支持
- [x] 粗体与斜体 (Strong & Emph) 支持
- [x] 块级引用 (Blockquote) 支持
- [x] 栅栏代码块 (Fenced Code Block) 支持
- [ ] 列表解析 (List - Ordered/Unordered) (进行中)
- [ ] GFM 表格支持 (计划中)

## 🤝 参与贡献

我们非常欢迎任何形式的贡献！无论是提交 Bug 报告、完善文档，还是提交合并请求（Pull Request）。
在提交 PR 之前，请务必执行以下命令以保证代码规范与测试通过：

```bash
moon fmt
moon test
```

## 📄 许可证

本项目基于 [Apache License 2.0](LICENSE) 协议开源。
