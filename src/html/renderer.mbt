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
pub struct Renderer {
  mut out : String
}

///|
pub fn Renderer::new() -> Renderer {
  { out: "" }
}

///|
pub fn Renderer::render(self : Renderer, doc : @ast.Document) -> String {
  self.out = ""
  for i = 0; i < doc.blocks.length(); i = i + 1 {
    self.render_block(doc.blocks[i])
  }
  self.out
}

///|
pub fn sanitize_url(url : StringView) -> String {
  let trimmed = url.trim()
  let len = trimmed.length()

  let mut colon_idx = -1
  for i = 0; i < len; i = i + 1 {
    let ch = trimmed[i]
    if ch == 58 { // ':'
      colon_idx = i
      break
    }
    if ch == 32 || ch == 47 || ch == 63 || ch == 35 {
      break
    }
  }

  if colon_idx > 0 {
    let mut scheme = ""
    for i = 0; i < colon_idx; i = i + 1 {
      let ch = trimmed[i]
      let lower_ch = if ch >= 65 && ch <= 90 { ch + 32 } else { ch }
      match lower_ch.to_int().to_char() {
        Some(c) => scheme = scheme + c.to_string()
        None => ()
      }
    }

    if scheme == "javascript" || scheme == "vbscript" || scheme == "file" {
      return "#"
    }
    if scheme == "data" {
      let s = trimmed.to_owned()
      if !s.has_prefix("data:image/") {
        return "#"
      }
    }
  }

  escape_html(trimmed)
}

///|
fn Renderer::render_block(self : Renderer, block : @ast.Block) -> Unit {
  match block {
    @ast.Heading(_, level, inlines) => {
      self.out = self.out + "<h" + level.to_string() + ">"
      self.render_inlines(inlines)
      self.out = self.out + "</h" + level.to_string() + ">\n"
    }
    @ast.Paragraph(_, inlines) => {
      self.out = self.out + "<p>"
      self.render_inlines(inlines)
      self.out = self.out + "</p>\n"
    }
    @ast.Blockquote(_, blocks) => {
      self.out = self.out + "<blockquote>\n"
      for i = 0; i < blocks.length(); i = i + 1 {
        self.render_block(blocks[i])
      }
      self.out = self.out + "</blockquote>\n"
    }
    @ast.CodeBlock(_, info, code) => {
      let lang_class = if info.length() > 0 {
        " class=\"language-" + escape_html(info) + "\""
      } else {
        ""
      }
      self.out = self.out +
        "<pre><code" +
        lang_class +
        ">" +
        escape_html(code) +
        "</code></pre>\n"
    }
    @ast.List(_, is_ordered, items) => {
      let tag = if is_ordered { "ol" } else { "ul" }
      self.out = self.out + "<" + tag + ">\n"
      for i = 0; i < items.length(); i = i + 1 {
        self.out = self.out + "<li>"
        let item_blocks = items[i]
        for j = 0; j < item_blocks.length(); j = j + 1 {
          self.render_block(item_blocks[j])
        }
        self.out = self.out + "</li>\n"
      }
      self.out = self.out + "</" + tag + ">\n"
    }
  }
}

///|
fn Renderer::render_inlines(
  self : Renderer,
  inlines : Array[@ast.Inline],
) -> Unit {
  for i = 0; i < inlines.length(); i = i + 1 {
    match inlines[i] {
      @ast.Text(_, s) => self.out = self.out + escape_html(s)
      @ast.Strong(_, inner) => {
        self.out = self.out + "<strong>"
        self.render_inlines(inner)
        self.out = self.out + "</strong>"
      }
      @ast.Emph(_, inner) => {
        self.out = self.out + "<em>"
        self.render_inlines(inner)
        self.out = self.out + "</em>"
      }
      @ast.CodeSpan(_, c) =>
        self.out = self.out + "<code>" + escape_html(c) + "</code>"
      @ast.Link(_, url, inner) => {
        self.out = self.out + "<a href=\"" + sanitize_url(url) + "\">"
        self.render_inlines(inner)
        self.out = self.out + "</a>"
      }
      @ast.Image(_, url, alt) =>
        self.out = self.out +
          "<img src=\"" +
          sanitize_url(url) +
          "\" alt=\"" +
          escape_html(alt) +
          "\">"
    }
  }
}
