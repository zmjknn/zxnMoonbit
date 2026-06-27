pub enum Inline {
  Text(String)
  Strong(Array[Inline])
  Emph(Array[Inline])
  CodeSpan(String)
  Link(String, Array[Inline], String)
}

pub enum Block {
  Heading(Int, Array[Inline])
  Paragraph(Array[Inline])
  CodeBlock(String, String)
}

pub struct Document {
  pub blocks : Array[Block]
}
