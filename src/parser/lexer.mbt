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

pub struct Lexer {
  input : String
  mut pos : Int
}

pub fn Lexer::new(input : String) -> Lexer {
  { input, pos: 0 }
}

pub fn Lexer::is_eof(self : Lexer) -> Bool {
  self.pos >= self.input.length()
}

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

pub fn Lexer::advance(self : Lexer) -> Unit {
  if !self.is_eof() {
    self.pos = self.pos + 1
  }
}

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
