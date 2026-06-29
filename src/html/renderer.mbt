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
\npub struct Renderer { mut out: String }
pub fn Renderer::new() -> Renderer { { out: "" } }

pub fn Renderer::render(self: Renderer, doc: @ast.Document) -> String {
  self.out = ""
  for i = 0; i < doc.blocks.length(); i = i + 1 { self.render_block(doc.blocks[i]) }
  self.out
}

fn Renderer::render_block(self: Renderer, block: @ast.Block) -> Unit {
  match block {
    Heading(level, inlines) => {
      self.out = self.out + "<h" + level.to_string() + ">"
      self.render_inlines(inlines)
      self.out = self.out + "</h" + level.to_string() + ">\n"
    }
    Paragraph(inlines) => {
      self.out = self.out + "<p>"
      self.render_inlines(inlines)
      self.out = self.out + "</p>\n"
    }
    _ => ()
  }
}

fn Renderer::render_inlines(self: Renderer, inlines: Array[@ast.Inline]) -> Unit {
  for i = 0; i < inlines.length(); i = i + 1 {
    match inlines[i] {
      Text(s) => self.out = self.out + escape_html(s)
      Strong(inner) => { self.out = self.out + "<strong>"; self.render_inlines(inner); self.out = self.out + "</strong>" }
      _ => ()
    }
  }
}
