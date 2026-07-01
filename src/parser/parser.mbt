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

pub struct Parser {
  lexer : Lexer
}

pub fn Parser::new(input : String) -> Parser {
  { lexer: Lexer::new(input) }
}

fn Parser::parse_heading(self : Parser) -> @ast.Block? {
  self.lexer.skip_whitespace()
  let mut level = 0
  while self.lexer.peek() == '#' && level < 6 {
    level = level + 1
    self.lexer.advance()
  }
  if level > 0 && self.lexer.peek() == ' ' {
    self.lexer.advance()
    let mut content = ""
    while !self.lexer.is_eof() && self.lexer.peek() != '\n' {
      content = content + self.lexer.peek().to_string()
      self.lexer.advance()
    }
    if self.lexer.peek() == '\n' {
      self.lexer.advance()
    }
    return Some(@ast.Heading(level, parse_inline(content.trim().to_owned())))
  }
  None
}

fn Parser::parse_fenced_code_block(self : Parser) -> @ast.Block? {
  self.lexer.skip_whitespace()
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
  
  let mut info = ""
  while self.lexer.peek() != '\n' && !self.lexer.is_eof() {
    info = info + self.lexer.peek().to_string()
    self.lexer.advance()
  }
  if self.lexer.peek() == '\n' {
    self.lexer.advance()
  }
  
  let mut code = ""
  while !self.lexer.is_eof() {
    let saved_pos = self.lexer.pos
    let mut close_count = 0
    while self.lexer.peek() == '`' {
      close_count = close_count + 1
      self.lexer.advance()
    }
    if close_count >= count && (self.lexer.peek() == '\n' || self.lexer.is_eof()) {
      if self.lexer.peek() == '\n' {
        self.lexer.advance()
      }
      break
    }
    self.lexer.pos = saved_pos
    code = code + self.lexer.peek().to_string()
    self.lexer.advance()
  }
  Some(@ast.CodeBlock(info.trim().to_owned(), code))
}

fn Parser::parse_blockquote(self : Parser) -> @ast.Block? {
  self.lexer.skip_whitespace()
  if self.lexer.peek() != '>' {
    return None
  }
  self.lexer.advance()
  if self.lexer.peek() == ' ' {
    self.lexer.advance()
  }
  
  let mut inner = ""
  while !self.lexer.is_eof() {
    let ch = self.lexer.peek()
    inner = inner + ch.to_string()
    self.lexer.advance()
    if ch == '\n' {
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
  Some(@ast.Blockquote(inner_p.parse().blocks))
}

fn Parser::parse_list(self : Parser) -> @ast.Block? {
  self.lexer.skip_whitespace()
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
  let mut current_item = ""
  while !self.lexer.is_eof() {
    let next_ch = self.lexer.peek()
    if next_ch == '\n' {
      self.lexer.advance()
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
        let item_p = Parser::new(current_item)
        items.push(item_p.parse().blocks)
        current_item = ""
        if is_ordered {
          while self.lexer.peek() >= '0' && self.lexer.peek() <= '9' {
            self.lexer.advance()
          }
          self.lexer.advance()
          self.lexer.advance()
        } else {
          self.lexer.advance()
          self.lexer.advance()
        }
      } else {
        current_item = current_item + "\n"
      }
    } else {
      current_item = current_item + next_ch.to_string()
      self.lexer.advance()
    }
  }
  if current_item.length() > 0 {
    let item_p = Parser::new(current_item)
    items.push(item_p.parse().blocks)
  }
  
  Some(@ast.List(is_ordered, items))
}

fn Parser::parse_paragraph(self : Parser) -> @ast.Block? {
  let mut content = ""
  while !self.lexer.is_eof() {
    let ch = self.lexer.peek()
    if ch == '\n' {
      self.lexer.advance()
      if self.lexer.peek() == '\n' {
        break
      }
      content = content + "\n"
    } else {
      content = content + ch.to_string()
      self.lexer.advance()
    }
  }
  if content.length() > 0 {
    return Some(@ast.Paragraph(parse_inline(content.trim().to_owned())))
  }
  None
}

pub fn Parser::parse(self : Parser) -> @ast.Document {
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
  @ast.Document::{ blocks }
}
