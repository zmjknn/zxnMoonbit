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
test "parser heading and spans" {
  let p = Parser::new("# Heading 1\n## Heading 2")
  let doc = p.parse()
  assert_eq(doc.blocks.length(), 2)

  // Verify AST representation
  match doc.blocks[0] {
    @ast.Heading(span, level, inlines) => {
      assert_eq(level, 1)
      assert_eq(span.start.line, 1)
      assert_eq(span.start.column, 1)
      assert_eq(inlines.length(), 1)
      match inlines[0] {
        @ast.Text(_, text) => assert_eq(text, "Heading 1")
        _ => fail("expected text")
      }
    }
    _ => fail("expected heading")
  }
}

///|
test "HTML rendering and escaping" {
  let p = Parser::new(
    "This is `<script>alert(\"XSS\")</script>` escaping test & 'single quote'.",
  )
  let doc = p.parse()
  let html = @html.Renderer::new().render(doc)
  // Escaping verification
  assert_eq(
    html, "<p>This is <code>&lt;script&gt;alert(&quot;XSS&quot;)&lt;/script&gt;</code> escaping test &amp; &#39;single quote&#39;.</p>\n",
  )
}

///|
test "parser paragraph and complex inlines" {
  let p = Parser::new(
    "This is **bold** and *italic* and `code` and [link](url) and ![image](img_url).",
  )
  let doc = p.parse()
  assert_eq(doc.blocks.length(), 1)

  let html = @html.Renderer::new().render(doc)
  assert_eq(
    html, "<p>This is <strong>bold</strong> and <em>italic</em> and <code>code</code> and <a href=\"url\">link</a> and <img src=\"img_url\" alt=\"image\">.</p>\n",
  )
}

///|
test "parser code block" {
  let p = Parser::new("```moonbit\nlet a = 1\n```")
  let doc = p.parse()
  assert_eq(doc.blocks.length(), 1)

  let html = @html.Renderer::new().render(doc)
  assert_eq(
    html, "<pre><code class=\"language-moonbit\">let a = 1\n</code></pre>\n",
  )
}

///|
test "parser blockquote" {
  let p = Parser::new("> This is a blockquote\n> containing a paragraph.")
  let doc = p.parse()
  assert_eq(doc.blocks.length(), 1)

  let html = @html.Renderer::new().render(doc)
  assert_eq(
    html, "<blockquote>\n<p>This is a blockquote\ncontaining a paragraph.</p>\n</blockquote>\n",
  )
}

///|
test "parser list" {
  let p = Parser::new("- Item 1\n- Item 2\n- Item 3")
  let doc = p.parse()
  assert_eq(doc.blocks.length(), 1)

  let html = @html.Renderer::new().render(doc)
  assert_eq(
    html, "<ul>\n<li><p>Item 1</p>\n</li>\n<li><p>Item 2</p>\n</li>\n<li><p>Item 3</p>\n</li>\n</ul>\n",
  )
}
