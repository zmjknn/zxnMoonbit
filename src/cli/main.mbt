pub fn main() {
  let demo = "## MoonMark\n一个纯 MoonBit 实现的解析器！"
  let parser = @parser.Parser::new(demo)
  let ast = parser.parse()
  let html = @html.Renderer::new().render(ast)
  println(html)
}
