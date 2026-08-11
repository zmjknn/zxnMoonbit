# MoonMark - High-Performance MoonBit Markdown Parser

[![MoonBit](https://img.shields.io/badge/MoonBit-0.10.3-orange.svg)](https://moonbitlang.com)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Build Status](https://github.com/zmjknn/zxnMoonbit/actions/workflows/ci.yml/badge.svg)](https://github.com/zmjknn/zxnMoonbit/actions)

MoonMark is a lightweight, blazing-fast Markdown parser and HTML rendering engine built entirely from scratch in [MoonBit](https://www.moonbitlang.com/). Designed with **CommonMark** compatibility in mind, MoonMark provides a solid foundation for Static Site Generators (SSG), document preview tools, and rich-text editor backends.

[中文文档](README_zh.md) | [References & Acknowledgments](REFERENCES.md)

---

## 🌟 Key Features & Implementation Guarantees

### 1. 🚀 StringView-Backed Parsing Architecture
- **Memory View Design**: Text payloads in AST nodes (`Text`, `CodeSpan`, `Link`, `Image`, `CodeBlock`) use native MoonBit `StringView` slices when the parser can preserve the source slice.
- **Measured, Not Guaranteed**: Flat block/inline parsing avoids copying text spans; normalized nested blocks may allocate temporary source buffers. Benchmark results depend on the toolchain and machine.

### 2. 📍 Precise Source Mapping (Span Tracking)
- The `Position` struct tracks **1-based line numbers**, **1-based column numbers**, and **0-based character offsets**.
- Every `Block` and `Inline` AST node contains exact `span : Span` metadata (`start` and `end`), ideal for IDE syntax highlighting, diagnostic linters, and refactoring tools.

### 3. 🛡️ Defensive HTML Rendering
- **HTML Entity Escaping**: Strict escaping for `<` (`&lt;`), `>` (`&gt;`), `&` (`&amp;`), `"` (`&quot;`), and `'` (`&#39;`).
- **URL Protocol Sanitization (`sanitize_url`)**: Scans `Link` and `Image` schemes, rejects `javascript:`, `vbscript:`, `file:`, and unsafe `data:` payloads, and escapes safe values before placing them in attributes. This is a renderer defense layer, not a replacement for a Content Security Policy.

### 4. 📦 Batch Conversion & Powerful CLI
- **Out-of-the-Box CLI**: Supports single-file conversion, multi-file batch conversion (`--batch`), and recursive directory batch processing (`--dir`) while preserving relative subdirectories.
- **Auto Directory Creation**: Automatically invokes filesystem APIs to create missing target directories.

---

## 🏗️ Architecture Overview

```text
moonmark/
├── src/ast/       # Core AST definitions using StringView and Span
├── src/parser/    # State-machine Lexer and recursive descent Parser
├── src/html/      # HTML escaper, URL sanitizer, and Renderer
├── src/cli/       # CLI application with batch conversion modes
└── benches/       # Performance benchmarking suite
```

---

## 🛠️ Installation & Reproduction Steps

### 1. Install MoonBit Toolchain

Install a stable MoonBit toolchain compatible with this module, then verify it with:
```bash
moon version
```

### 2. Clone Repository & Run Checks

```bash
git clone https://github.com/zmjknn/zxnMoonbit.git
cd zxnMoonbit

# 1. Type check
moon check --deny-warn

# 2. Run unit tests
moon test

# 3. Benchmark suite
moon bench

# 4. Format check
moon fmt --check

# 5. Interface signature check
moon info
```

---

## 💻 CLI User Guide

### 1. Demo Mode
```bash
moon run src/cli
```

### 2. Single File Conversion
```bash
moon run src/cli -- input.md -o output.html
```

### 3. Multi-File Batch Conversion (`--batch` / `-b`)
```bash
moon run src/cli -- --batch README.md README_zh.md -o dist/
```

### 4. Directory Batch Conversion (`--dir` / `-d`)
Recursively converts all `.md` and `.markdown` files in the specified input directory to `.html` in the target folder, preserving relative subdirectories:
```bash
moon run src/cli -- --dir docs/ -o dist/
# docs/guide/start.md -> dist/guide/start.html
```

### 5. Help Menu
```bash
moon run src/cli -- --help
```

---

## 📚 Prior Art & References

MoonMark borrows architectural patterns and specification ideas from the following open-source projects:

1. **[marked.js](https://github.com/markedjs/marked)** (MIT License)
   - **Reference Scope**: AST node taxonomy (Block/Inline division), HTML escaping rules, and CLI flag patterns.
2. **[pulldown-cmark](https://github.com/pulldown-cmark/pulldown-cmark)** (MIT License)
   - **Reference Scope**: Zero-allocation state-machine lexing model using string slices, event-driven parsing flow, and CommonMark compliance testing strategies.

For full details, licenses, and reference statements, see [REFERENCES.md](REFERENCES.md).

---

## 📄 License

This project is open-sourced under the [Apache License 2.0](LICENSE).
