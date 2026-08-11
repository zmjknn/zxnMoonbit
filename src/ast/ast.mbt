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
pub(all) struct Position {
  line : Int
  column : Int
}

///|
pub(all) struct Span {
  start : Position
  end : Position
}

///|
pub(all) enum Inline {
  Text(Span, String)
  Strong(Span, Array[Inline])
  Emph(Span, Array[Inline])
  CodeSpan(Span, String)
  Link(Span, String, Array[Inline])
  Image(Span, String, String)
}

///|
pub(all) enum Block {
  Heading(Span, Int, Array[Inline])
  Paragraph(Span, Array[Inline])
  Blockquote(Span, Array[Block])
  CodeBlock(Span, String, String)
  List(Span, Bool, Array[Array[Block]])
}

///|
pub(all) struct Document {
  span : Span
  blocks : Array[Block]
}
