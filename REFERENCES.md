# References and Prior Art Acknowledgments

MoonMark refers to and incorporates architectural principles from the following open-source projects:

## 1. marked.js

- **Project Name**: `marked`
- **Repository Link**: [https://github.com/markedjs/marked](https://github.com/markedjs/marked)
- **License**: MIT License ([https://github.com/markedjs/marked/blob/master/LICENSE.md](https://github.com/markedjs/marked/blob/master/LICENSE.md))
- **Reference Scope & Influence**:
  - AST taxonomy design (Block vs. Inline node separation).
  - HTML entity escaping rules and XSS defense patterns.
  - CLI argument conventions and batch processing workflows.

---

## 2. pulldown-cmark

- **Project Name**: `pulldown-cmark`
- **Repository Link**: [https://github.com/pulldown-cmark/pulldown-cmark](https://github.com/pulldown-cmark/pulldown-cmark)
- **License**: MIT License ([https://github.com/pulldown-cmark/pulldown-cmark/blob/master/LICENSE](https://github.com/pulldown-cmark/pulldown-cmark/blob/master/LICENSE))
- **Reference Scope & Influence**:
  - Zero-allocation state-machine lexing model.
  - Event-driven string slice parsing concepts using string views.
  - CommonMark compliance test case structure and span mapping.
