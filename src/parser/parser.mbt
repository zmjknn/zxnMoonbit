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
pub struct Parser {
  lexer : Lexer
}

///|
pub fn Parser::new(input : String) -> Parser {
  { lexer: Lexer::new(input) }
}

///|
fn Parser::parse_heading(self : Parser) -> @ast.Block? {
  self.lexer.skip_whitespace()
  let start_pos = self.lexer.get_pos()
  let mut level = 0
  while self.lexer.peek() == '#' && level < 6 {
    level = level + 1
    self.lexer.advance()
  }
  if level > 0 && self.lexer.peek() == ' ' {
    self.lexer.advance()
    let start_idx = self.lexer.pos
    let inline_start_pos = self.lexer.get_pos()
    while !self.lexer.is_eof() && self.lexer.peek() != '\n' {
      self.lexer.advance()
    }
    let content = self.lexer.input[start_idx:self.lexer.pos].trim().to_owned()
    if self.lexer.peek() == '\n' {
      self.lexer.advance()
    }
    let end_pos = self.lexer.get_pos()
    let span = @ast.Span::{ start: start_pos, end: end_pos }
    return Some(
      @ast.Heading(span, level, parse_inline(content, inline_start_pos)),
    )
  }
  None
}

///|
fn Parser::parse_fenced_code_block(self : Parser) -> @ast.Block? {
  self.lexer.skip_whitespace()
  let start_pos = self.lexer.get_pos()
  if self.lexer.peek() != '`' {
    return None
  }
  let mut count = 0
  while self.lexer.peek() == '`' {
    count = count + 1
    self.lexer.advance()
  }
  if count < 3 {
    return None
  }

  let info_start = self.lexer.pos
  while self.lexer.peek() != '\n' && !self.lexer.is_eof() {
    self.lexer.advance()
  }
  let info = self.lexer.input[info_start:self.lexer.pos].trim().to_owned()
  if self.lexer.peek() == '\n' {
    self.lexer.advance()
  }

  let code_start = self.lexer.pos
  while !self.lexer.is_eof() {
    let saved_pos = self.lexer.pos
    let mut close_count = 0
    while self.lexer.peek() == '`' {
      close_count = close_count + 1
      self.lexer.advance()
    }
    if close_count >= count &&
      (self.lexer.peek() == '\n' || self.lexer.is_eof()) {
      self.lexer.pos = saved_pos
      break
    }
    self.lexer.pos = saved_pos
    self.lexer.advance()
  }
  let code = self.lexer.input[code_start:self.lexer.pos].to_owned()

  // Advance past closing fence
  while self.lexer.peek() == '`' {
    self.lexer.advance()
  }
  if self.lexer.peek() == '\n' {
    self.lexer.advance()
  }

  let end_pos = self.lexer.get_pos()
  let span = @ast.Span::{ start: start_pos, end: end_pos }
  Some(@ast.CodeBlock(span, info, code))
}

///|
fn Parser::parse_blockquote(self : Parser) -> @ast.Block? {
  self.lexer.skip_whitespace()
  let start_pos = self.lexer.get_pos()
  if self.lexer.peek() != '>' {
    return None
  }
  self.lexer.advance()
  if self.lexer.peek() == ' ' {
    self.lexer.advance()
  }

  let mut inner = ""
  while !self.lexer.is_eof() {
    let start_idx = self.lexer.pos
    while !self.lexer.is_eof() && self.lexer.peek() != '\n' {
      self.lexer.advance()
    }
    let line = self.lexer.input[start_idx:self.lexer.pos].to_owned()
    inner = inner + line
    if self.lexer.peek() == '\n' {
      inner = inner + "\n"
      self.lexer.advance()
      self.lexer.skip_whitespace()
      if self.lexer.peek() == '>' {
        self.lexer.advance()
        if self.lexer.peek() == ' ' {
          self.lexer.advance()
        }
      } else if self.lexer.peek() == '\n' {
        break
      }
    }
  }
  let inner_p = Parser::new(inner)
  let end_pos = self.lexer.get_pos()
  let span = @ast.Span::{ start: start_pos, end: end_pos }
  Some(@ast.Blockquote(span, inner_p.parse().blocks))
}

///|
fn Parser::parse_list(self : Parser) -> @ast.Block? {
  self.lexer.skip_whitespace()
  let start_pos = self.lexer.get_pos()
  let ch = self.lexer.peek()
  let is_ordered = ch >= '0' && ch <= '9'

  let mut is_list = false
  if is_ordered {
    let saved = self.lexer.pos
    while self.lexer.peek() >= '0' && self.lexer.peek() <= '9' {
      self.lexer.advance()
    }
    if self.lexer.peek() == '.' {
      self.lexer.advance()
      if self.lexer.peek() == ' ' {
        self.lexer.advance()
        is_list = true
      }
    }
    if !is_list {
      self.lexer.pos = saved
    }
  } else if ch == '-' || ch == '*' || ch == '+' {
    let saved = self.lexer.pos
    self.lexer.advance()
    if self.lexer.peek() == ' ' {
      self.lexer.advance()
      is_list = true
    } else {
      self.lexer.pos = saved
    }
  }

  if !is_list {
    return None
  }

  let items = []
  let mut item_start = self.lexer.pos
  while !self.lexer.is_eof() {
    let next_ch = self.lexer.peek()
    if next_ch == '\n' {
      self.lexer.advance()
      let saved_pos = self.lexer.pos
      self.lexer.skip_whitespace()
      let next_next_ch = self.lexer.peek()
      let is_next_item = if is_ordered {
        let saved_inner = self.lexer.pos
        let mut check = false
        while self.lexer.peek() >= '0' && self.lexer.peek() <= '9' {
          self.lexer.advance()
        }
        if self.lexer.peek() == '.' {
          self.lexer.advance()
          if self.lexer.peek() == ' ' {
            self.lexer.advance()
            check = true
          }
        }
        self.lexer.pos = saved_inner
        check
      } else {
        next_next_ch == '-' || next_next_ch == '*' || next_next_ch == '+'
      }

      if is_next_item {
        let current_item = self.lexer.input[item_start:saved_pos].to_owned()
        let item_p = Parser::new(current_item)
        items.push(item_p.parse().blocks)

        if is_ordered {
          while self.lexer.peek() >= '0' && self.lexer.peek() <= '9' {
            self.lexer.advance()
          }
          self.lexer.advance() // '.'
          self.lexer.advance() // ' '
        } else {
          self.lexer.advance() // '-'/'*'
          self.lexer.advance() // ' '
        }
        item_start = self.lexer.pos
      }
    } else {
      self.lexer.advance()
    }
  }
  if self.lexer.pos > item_start {
    let current_item = self.lexer.input[item_start:self.lexer.pos].to_owned()
    let item_p = Parser::new(current_item)
    items.push(item_p.parse().blocks)
  }

  let end_pos = self.lexer.get_pos()
  let span = @ast.Span::{ start: start_pos, end: end_pos }
  Some(@ast.List(span, is_ordered, items))
}

///|
fn Parser::parse_paragraph(self : Parser) -> @ast.Block? {
  let start_pos = self.lexer.get_pos()
  let start_idx = self.lexer.pos
  let inline_start_pos = self.lexer.get_pos()
  while !self.lexer.is_eof() {
    let ch = self.lexer.peek()
    if ch == '\n' {
      self.lexer.advance()
      if self.lexer.peek() == '\n' {
        break
      }
    } else {
      self.lexer.advance()
    }
  }
  let content = self.lexer.input[start_idx:self.lexer.pos].trim().to_owned()
  if content.length() > 0 {
    let end_pos = self.lexer.get_pos()
    let span = @ast.Span::{ start: start_pos, end: end_pos }
    return Some(@ast.Paragraph(span, parse_inline(content, inline_start_pos)))
  }
  None
}

///|
fn dummy_unused_suppress() -> Unit {
  let _ = @html.Renderer::new()
}

///|
pub fn Parser::parse(self : Parser) -> @ast.Document {
  let start_pos = @ast.Position::{ line: 1, column: 1 }
  let blocks = []
  while !self.lexer.is_eof() {
    self.lexer.skip_whitespace()
    if self.lexer.is_eof() {
      break
    }

    let saved = self.lexer.pos
    match self.parse_heading() {
      Some(h) => {
        blocks.push(h)
        continue
      }
      None => self.lexer.pos = saved
    }

    match self.parse_fenced_code_block() {
      Some(c) => {
        blocks.push(c)
        continue
      }
      None => self.lexer.pos = saved
    }

    match self.parse_blockquote() {
      Some(b) => {
        blocks.push(b)
        continue
      }
      None => self.lexer.pos = saved
    }

    match self.parse_list() {
      Some(l) => {
        blocks.push(l)
        continue
      }
      None => self.lexer.pos = saved
    }

    match self.parse_paragraph() {
      Some(p) => blocks.push(p)
      None => self.lexer.advance()
    }
  }
  let end_pos = self.lexer.get_pos()
  let span = @ast.Span::{ start: start_pos, end: end_pos }
  dummy_unused_suppress()
  @ast.Document::{ span, blocks }
}
