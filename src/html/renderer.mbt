pub struct Renderer { mut out: String }
pub fn Renderer::new() -> Renderer { { out: "" } }

pub fn Renderer::render(self: Renderer, doc: @ast.Document) -> String {
  self.out = ""
  for i = 0; i < doc.blocks.length(); i = i + 1 { self.render_block(doc.blocks[i]) }
  self.out
}

fn Renderer::render_block(self: Renderer, block: @ast.Block) -> Unit {
  match block {
    Heading(level, inlines) => {
      self.out = self.out + "<h" + level.to_string() + ">"
      self.render_inlines(inlines)
      self.out = self.out + "</h" + level.to_string() + ">\n"
    }
    Paragraph(inlines) => {
      self.out = self.out + "<p>"
      self.render_inlines(inlines)
      self.out = self.out + "</p>\n"
    }
    _ => ()
  }
}

fn Renderer::render_inlines(self: Renderer, inlines: Array[@ast.Inline]) -> Unit {
  for i = 0; i < inlines.length(); i = i + 1 {
    match inlines[i] {
      Text(s) => self.out = self.out + escape_html(s)
      Strong(inner) => { self.out = self.out + "<strong>"; self.render_inlines(inner); self.out = self.out + "</strong>" }
      _ => ()
    }
  }
}
