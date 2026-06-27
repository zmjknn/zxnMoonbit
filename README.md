# MoonMark - High-Performance MoonBit Markdown Parser

[![MoonBit](https://img.shields.io/badge/MoonBit-0.1.0-orange.svg)](https://moonbitlang.com)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Build Status](https://github.com/zmjknn/zxnMoonbit/actions/workflows/ci.yml/badge.svg)](https://github.com/zmjknn/zxnMoonbit/actions)

*中文说明请参阅 [README_zh.md](README_zh.md)*

MoonMark is a lightweight, blazing-fast Markdown parser and HTML rendering engine built entirely from scratch in [MoonBit](https://www.moonbitlang.com/). Designed with **CommonMark** compatibility in mind, MoonMark provides a solid foundation for MoonBit developers building Static Site Generators (SSG), document preview tools, and rich-text editor backends.

## 🌟 Key Features

- **🚀 Extreme Performance**: Powered by MoonBit's aggressive compiler optimizations and a zero-allocation state-machine parsing architecture.
- **🛡️ Secure by Default**: Built-in HTML escaping and XSS defense mechanisms ensure that user-generated Markdown is safely rendered into HTML.
- **🧩 Extensible AST**: The parsing phase generates an Abstract Syntax Tree (AST) with precise span information (line/column tracking), making it easy to build custom linters or GFM extensions (like tables and task lists).
- **📦 Modular Design**: Structured as a multi-package MoonBit workspace, cleanly separating Lexer, Parser, AST definitions, and Renderer logic.

## 🏗️ Architecture Overview

MoonMark follows an enterprise-grade open-source architecture:

```text
moonmark/
├── src/ast/       # Core AST definitions for Block and Inline elements.
├── src/parser/    # State-machine driven Lexer and recursive descent Parser.
├── src/html/      # Safe HTML rendering and escaping utilities.
├── src/cli/       # Out-of-the-box Command Line Interface.
└── benches/       # Performance benchmarking suite.
```

## 🚀 Quick Start

### 1. Add as a dependency

In your `moon.pkg.json`, import the relevant MoonMark packages:
```json
{
  "import": [
    "zmjknn/moonmark/src/parser",
    "zmjknn/moonmark/src/html"
  ]
}
```

### 2. Basic Usage

```moonbit
pub fn main() {
  let markdown_text = 
    "# Hello MoonMark\n\nThis parser is written in **pure MoonBit**!"
  
  // 1. Initialize parser and build AST
  let p = @parser.Parser::new(markdown_text)
  let ast_document = p.parse()
  
  // 2. Render safely to HTML
  let html_output = @html.Renderer::new().render(ast_document)
  
  println(html_output)
}
```

## 📜 Roadmap

- [x] Core parsing architecture (Lexer/Parser loop)
- [x] Multi-level Headings
- [x] Paragraph formatting
- [x] Strong & Emphasis
- [x] Blockquotes
- [x] Fenced Code Blocks
- [ ] Lists (Ordered & Unordered) (WIP)
- [ ] GFM Tables (Planned)

## 🤝 Contributing

We welcome all contributions! Whether it's submitting bug reports, improving documentation, or opening Pull Requests.
Before submitting a PR, please ensure you run formatting and tests:

```bash
moon fmt
moon test
```

## 📄 License

This project is open-sourced under the [Apache License 2.0](LICENSE).
