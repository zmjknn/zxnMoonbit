pub struct Lexer {
  input: String
  mut pos: Int
}

pub fn Lexer::new(input: String) -> Lexer { { input, pos: 0 } }
pub fn Lexer::is_eof(self: Lexer) -> Bool { self.pos >= self.input.length() }
pub fn Lexer::peek(self: Lexer) -> Char { if self.is_eof() { '\x00' } else { self.input[self.pos] } }
pub fn Lexer::advance(self: Lexer) -> Unit { if not(self.is_eof()) { self.pos = self.pos + 1 } }

pub fn Lexer::skip_whitespace(self: Lexer) -> Unit {
  while not(self.is_eof()) {
    let ch = self.peek()
    if ch == ' ' || ch == '\t' { self.advance() } else { break }
  }
}
