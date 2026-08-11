# MoonMark - High-Performance MoonBit Markdown Parser

[![MoonBit](https://img.shields.io/badge/MoonBit-compatible-orange.svg)](https://www.moonbitlang.com/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Build Status](https://github.com/zmjknn/zxnMoonbit/actions/workflows/ci.yml/badge.svg)](https://github.com/zmjknn/zxnMoonbit/actions)

MoonMark is a lightweight Markdown parser and HTML rendering engine built entirely from scratch in [MoonBit](https://www.moonbitlang.com/). It targets a documented **CommonMark-oriented subset** and provides a foundation for Static Site Generators (SSG), document preview tools, and rich-text editor backends.

[中文文档](README_zh.md) | [References & Acknowledgments](REFERENCES.md)

---

## 🌟 Key Features & Implementation Guarantees

### 1. 🚀 StringView-Backed Parsing Architecture
- **Memory View Design**: Text payloads in AST nodes (`Text`, `CodeSpan`, `Link`, `Image`, `CodeBlock`) use native MoonBit `StringView` slices when the parser can preserve the source slice.
- **Measured, Not Guaranteed**: Flat block/inline parsing avoids copying text spans; normalized nested blocks may allocate temporary source buffers. Benchmark results depend on the toolchain and machine.

### 2. 📍 Precise Source Mapping (Span Tracking)
- The `Position` struct tracks **1-based line numbers**, **1-based columns**, and **0-based offsets** in the source string index model used by the parser; columns are not grapheme-cluster counts.
- Every `Block` and `Inline` AST node contains exact `span : Span` metadata (`start` and `end`), ideal for IDE syntax highlighting, diagnostic linters, and refactoring tools.

### 3. 🛡️ Defensive HTML Rendering
- **HTML Entity Escaping**: Strict escaping for `<` (`&lt;`), `>` (`&gt;`), `&` (`&amp;`), `"` (`&quot;`), and `'` (`&#39;`).
- **URL Protocol Sanitization (`sanitize_url`)**: Scans `Link` and `Image` schemes, rejects `javascript:`, `vbscript:`, `file:`, and unsafe `data:` payloads, and escapes safe values before placing them in attributes. This is a renderer defense layer, not a replacement for a Content Security Policy.

### 4. 📦 Batch Conversion & Powerful CLI
- **Out-of-the-Box CLI**: Supports single-file conversion, multi-file batch conversion (`--batch`), and recursive directory batch processing (`--dir`) while preserving relative subdirectories.
- **Auto Directory Creation**: Automatically invokes filesystem APIs to create missing target directories.

## Scope and Current Limits

- Supported constructs in this revision include headings, paragraphs, blockquotes, fenced code blocks, ordered and unordered lists, emphasis, strong emphasis, code spans, links, and images.
- Raw HTML is rendered as escaped text. This project does not claim full CommonMark conformance, raw-HTML passthrough, or extension-syntax compatibility.
- URL filtering is a defensive renderer layer. Applications should still validate untrusted input and deploy an appropriate Content Security Policy (CSP).
- `--dir` processes `.md` and `.markdown` files recursively and writes `.html` files while preserving relative directories; other file extensions are ignored.

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

# 5. Regenerate public interface files (review the generated diff)
moon info

# 6. CLI smoke test
moon run src/cli -- --help

# 7. Check patch formatting
git diff --check
```

`moon info` regenerates public `.mbti` interface files; it is not a pass/fail test by itself. Review generated changes before committing them.

If GNU Make is available, the equivalent shortcuts are `make check`, `make fmt-check`, `make test`, `make bench`, and `make cli-smoke`.

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

`--dir` creates missing output directories, preserves nested paths, and ignores files that are not `.md` or `.markdown`. Read/write failures are reported by the CLI; callers that need machine-readable failure handling should wrap the command and validate the output files.

---

## Validation Snapshot (this revision)

The repository currently contains 15 `.mbt` source/test files and 12 automated tests. The test matrix covers AST spans, nested block reconstruction, HTML escaping, dangerous URL schemes, safe raster `data:` URLs, empty input, Unicode text, and relative CLI output paths.

The benchmark suite contains three named workloads in `benches/bench.mbt`. One local baseline, measured with `moon 0.1.20260713` on Windows, was:

| Workload | Mean ± σ | Range | Harness runs |
| --- | ---: | ---: | ---: |
| flat markdown | 2.19 µs ± 132.08 ns | 2.04–2.42 µs | 10 × 49,233 |
| structured markdown | 3.01 µs ± 125.75 ns | 2.87–3.20 µs | 10 × 33,538 |
| Unicode and nested markdown | 6.77 µs ± 167.50 ns | 6.57–7.09 µs | 10 × 14,904 |

These numbers are a reproducible local baseline, not a cross-machine performance guarantee. Re-run `moon bench` on the target toolchain and hardware before making performance comparisons.

---

## 📚 Prior Art & References

MoonMark borrows architectural patterns and specification ideas from the following open-source projects:

1. **[marked.js](https://github.com/markedjs/marked)** (MIT License)
   - **Reference Scope**: AST node taxonomy (Block/Inline division), HTML escaping rules, and CLI flag patterns.
2. **[pulldown-cmark](https://github.com/pulldown-cmark/pulldown-cmark)** (MIT License)
   - **Reference Scope**: Zero-allocation state-machine lexing model using string slices, event-driven parsing flow, and CommonMark compliance testing strategies.

For full details, licenses, and reference statements, see [REFERENCES.md](REFERENCES.md).

No source code from these projects is bundled in MoonMark; the references document design influence and license boundaries only. MoonMark's own source is distributed under Apache-2.0.

---

## 📄 License

This project is open-sourced under the [Apache License 2.0](LICENSE).

Copyright 2026 zmjknn. Individual source files also carry the Apache-2.0 header; generated `.mbti` files are produced by the MoonBit toolchain.
