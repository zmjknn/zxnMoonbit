pub struct Parser { lexer: Lexer }
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
