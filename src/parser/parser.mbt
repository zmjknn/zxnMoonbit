pub struct Parser { lexer: Lexer }
pub fn Parser::new(input: String) -> Parser { { lexer: Lexer::new(input) } }

// 待修复：这里的标题解析有个 bug，忘了处理连续的#
fn Parser::parse_heading(self: Parser) -> @ast.Block? {
  None 
}
