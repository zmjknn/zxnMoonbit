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
\npub struct Parser { lexer: Lexer }
pub fn Parser::new(input: String) -> Parser { { lexer: Lexer::new(input) } }

fn Parser::parse_heading(self: Parser) -> @ast.Block? {
  self.lexer.skip_whitespace()
  let mut level = 0
  while self.lexer.peek() == '#' && level < 6 {
    level = level + 1; self.lexer.advance()
  }
  if level > 0 && self.lexer.peek() == ' ' {
    self.lexer.advance()
    let mut content = ""
    while not(self.lexer.is_eof()) && self.lexer.peek() != '\n' {
      content = content + self.lexer.peek().to_string()
      self.lexer.advance()
    }
    return Some(Heading(level, [Text(content.trim())]))
  }
  None
}

fn Parser::parse_paragraph(self: Parser) -> @ast.Block? {
  let mut content = ""
  while not(self.lexer.is_eof()) {
    let ch = self.lexer.peek()
    if ch == '\n' {
      self.lexer.advance()
      if self.lexer.peek() == '\n' { break }
      content = content + "\n"
    } else {
      content = content + ch.to_string()
      self.lexer.advance()
    }
  }
  if content.length() > 0 { return Some(Paragraph(parse_inline(content.trim()))) }
  None
}

pub fn Parser::parse(self: Parser) -> @ast.Document {
  let blocks = []
  while not(self.lexer.is_eof()) {
    self.lexer.skip_whitespace()
    if self.lexer.is_eof() { break }
    let saved = self.lexer.pos
    match self.parse_heading() {
      Some(h) => { blocks.push(h); continue }
      None => self.lexer.pos = saved
    }
    match self.parse_paragraph() {
      Some(p) => blocks.push(p)
      None => self.lexer.advance()
    }
  }
  { blocks }
}
