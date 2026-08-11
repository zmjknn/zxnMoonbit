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
pub struct Lexer {
  input : String
  mut pos : Int
  mut line : Int
  mut col : Int
  positions : Array[@ast.Position]?
}

///|
pub fn Lexer::new(input : String) -> Lexer {
  { input, pos: 0, line: 1, col: 1, positions: None }
}

///|
fn Lexer::new_with_positions(
  input : String,
  positions : Array[@ast.Position],
) -> Lexer {
  { input, pos: 0, line: 1, col: 1, positions: Some(positions) }
}

///|
pub fn Lexer::is_eof(self : Lexer) -> Bool {
  self.pos >= self.input.length()
}

///|
pub fn Lexer::peek(self : Lexer) -> Char {
  if self.is_eof() {
    '\u0000'
  } else {
    match self.input[self.pos].to_int().to_char() {
      Some(c) => c
      None => '\u0000'
    }
  }
}

///|
pub fn Lexer::advance(self : Lexer) -> Unit {
  if !self.is_eof() {
    let ch = self.peek()
    if ch == '\n' {
      self.line = self.line + 1
      self.col = 1
    } else {
      self.col = self.col + 1
    }
    self.pos = self.pos + 1
  }
}

///|
pub fn Lexer::get_pos(self : Lexer) -> @ast.Position {
  match self.positions {
    Some(positions) => positions[self.pos]
    None => { line: self.line, column: self.col, offset: self.pos }
  }
}

///|
fn Lexer::get_pos_at(self : Lexer, index : Int) -> @ast.Position {
  match self.positions {
    Some(positions) => positions[index]
    None => {
      let mut line = 1
      let mut column = 1
      let mut i = 0
      while i < index && i < self.input.length() {
        if self.input[i] == '\n' {
          line = line + 1
          column = 1
        } else {
          column = column + 1
        }
        i = i + 1
      }
      { line, column, offset: index }
    }
  }
}

///|
fn Lexer::get_positions(self : Lexer) -> Array[@ast.Position]? {
  self.positions
}

///|
fn build_positions(
  text : StringView,
  start_pos : @ast.Position,
) -> Array[@ast.Position] {
  let positions = []
  let mut pos = start_pos
  for i = 0; i <= text.length(); i = i + 1 {
    positions.push(pos)
    if i < text.length() {
      if text[i] == '\n' {
        pos = { line: pos.line + 1, column: 1, offset: pos.offset + 1 }
      } else {
        pos = { line: pos.line, column: pos.column + 1, offset: pos.offset + 1 }
      }
    }
  }
  positions
}

///|
pub fn Lexer::skip_whitespace(self : Lexer) -> Unit {
  while !self.is_eof() {
    let ch = self.peek()
    if ch == ' ' || ch == '\t' {
      self.advance()
    } else {
      break
    }
  }
}
