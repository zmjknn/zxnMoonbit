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
