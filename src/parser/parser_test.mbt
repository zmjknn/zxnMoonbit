// Copyright 2026 zmjknn
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
test "parser precise spans with offset" {
  let input = "# Heading 1\n## Heading 2"
  let p = Parser::new(input)
  let doc = p.parse()
  assert_eq(doc.blocks.length(), 2)

  match doc.blocks[0] {
    @ast.Heading(span, level, inlines) => {
      assert_eq(level, 1)
      assert_eq(span.start.line, 1)
      assert_eq(span.start.column, 1)
      assert_eq(span.start.offset, 0)
      assert_eq(inlines.length(), 1)
      match inlines[0] {
        @ast.Text(t_span, text) => {
          assert_eq(text, "Heading 1")
          assert_eq(t_span.start.line, 1)
          assert_eq(t_span.start.column, 3)
          assert_eq(t_span.start.offset, 2)
        }
        _ => fail("expected text inline")
      }
    }
    _ => fail("expected heading block")
  }
}

///|
test "complete XSS protection and URL sanitization" {
  let input =
    #|This is `<script>alert("XSS")</script>` and [xss_link](javascript:alert(1)) and ![xss_img](data:text/html;base64,PHNjcmlwdD4=).
  let p = Parser::new(input)
  let doc = p.parse()
  let html = @html.Renderer::new().render(doc)
  assert_eq(
    html, "<p>This is <code>&lt;script&gt;alert(&quot;XSS&quot;)&lt;/script&gt;</code> and <a href=\"#\">xss_link</a> and <img src=\"#\" alt=\"xss_img\">.</p>\n",
  )
}

///|
test "zero-allocation StringView AST payloads" {
  let input = "Hello **World** in `MoonBit`!"
  let p = Parser::new(input)
  let doc = p.parse()
  assert_eq(doc.blocks.length(), 1)
  match doc.blocks[0] {
    @ast.Paragraph(_, inlines) => {
      assert_eq(inlines.length(), 5)
      match inlines[0] {
        @ast.Text(_, text) => assert_eq(text, "Hello ")
        _ => fail("expected Text")
      }
      match inlines[2] {
        @ast.Text(_, text) => assert_eq(text, " in ")
        _ => fail("expected Text")
      }
      match inlines[3] {
        @ast.CodeSpan(_, code) => assert_eq(code, "MoonBit")
        _ => fail("expected CodeSpan")
      }
    }
    _ => fail("expected Paragraph")
  }
}

///|
test "parser code block and blockquote" {
  let input = "```moonbit\nlet x = 42\n```\n> Quote line 1\n> Quote line 2"
  let p = Parser::new(input)
  let doc = p.parse()
  assert_eq(doc.blocks.length(), 2)
  let html = @html.Renderer::new().render(doc)
  assert_eq(
    html, "<pre><code class=\"language-moonbit\">let x = 42\n</code></pre>\n<blockquote>\n<p>Quote line 1\nQuote line 2</p>\n</blockquote>\n",
  )
}

///|
test "parser list and images" {
  let input = "- Item 1\n- Item 2 with ![badge](https://example.com/img.png)"
  let p = Parser::new(input)
  let doc = p.parse()
  assert_eq(doc.blocks.length(), 1)
  let html = @html.Renderer::new().render(doc)
  assert_eq(
    html, "<ul>\n<li><p>Item 1</p>\n</li>\n<li><p>Item 2 with <img src=\"https://example.com/img.png\" alt=\"badge\"></p>\n</li>\n</ul>\n",
  )
}

///|
test "heading inline span skips extra marker whitespace" {
  let doc = Parser::new("#   Title").parse()
  match doc.blocks[0] {
    @ast.Heading(_, _, inlines) =>
      match inlines[0] {
        @ast.Text(span, _) => {
          assert_eq(span.start.column, 5)
          assert_eq(span.start.offset, 4)
        }
        _ => fail("expected text")
      }
    _ => fail("expected heading")
  }
}

///|
test "blockquote child spans keep original source coordinates" {
  let doc = Parser::new("> first\n> **second**").parse()
  match doc.blocks[0] {
    @ast.Blockquote(_, blocks) =>
      match blocks[0] {
        @ast.Paragraph(_, inlines) =>
          match inlines[1] {
            @ast.Strong(span, _) => {
              assert_eq(span.start.line, 2)
              assert_eq(span.start.column, 3)
              assert_eq(span.start.offset, 10)
            }
            _ => fail("expected second strong")
          }
        _ => fail("expected paragraph")
      }
    _ => fail("expected blockquote")
  }
}

///|
test "list child spans keep original source coordinates" {
  let doc = Parser::new("- first\n- **second**").parse()
  match doc.blocks[0] {
    @ast.List(_, _, items) =>
      match items[1][0] {
        @ast.Paragraph(_, inlines) =>
          match inlines[0] {
            @ast.Strong(span, _) => {
              assert_eq(span.start.line, 2)
              assert_eq(span.start.column, 3)
              assert_eq(span.start.offset, 10)
            }
            _ => fail("expected strong")
          }
        _ => fail("expected paragraph")
      }
    _ => fail("expected list")
  }
}

///|
test "URL sanitization rejects case and control-character scheme bypasses" {
  assert_eq(@html.sanitize_url("JaVaScRiPt:alert(1)"), "#")
  assert_eq(@html.sanitize_url("\u0000javascript:alert(1)"), "#")
  assert_eq(
    @html.sanitize_url("https://example.com/\" onerror=alert(1)"),
    "https://example.com/&quot; onerror=alert(1)",
  )
}

///|
test "empty and Unicode documents keep stable boundaries" {
  let empty = Parser::new("").parse()
  assert_eq(empty.blocks.length(), 0)
  assert_eq(empty.span.start.line, 1)
  assert_eq(empty.span.start.column, 1)
  assert_eq(empty.span.start.offset, 0)
  assert_eq(empty.span.end.offset, 0)

  let unicode = Parser::new("你好，MoonBit 😀").parse()
  let html = @html.Renderer::new().render(unicode)
  assert_eq(html, "<p>你好，MoonBit 😀</p>\n")
}

///|
test "URL policy covers dangerous data and safe raster data" {
  assert_eq(@html.sanitize_url(" file:///tmp/image.png "), "#")
  assert_eq(
    @html.sanitize_url("data:image/svg+xml,<svg onload=alert(1) />"),
    "#",
  )
  assert_eq(
    @html.sanitize_url("data:image/png;base64,AAAA"),
    "data:image/png;base64,AAAA",
  )
  assert_eq(
    @html.sanitize_url("  HTTPS://example.com/path  "),
    "HTTPS://example.com/path",
  )
}
