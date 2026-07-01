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

pub(all) enum Inline {
  Text(String)
  Strong(Array[Inline])
  Emph(Array[Inline])
  CodeSpan(String)
  Link(String, Array[Inline])
  Image(String, String)
}

pub(all) enum Block {
  Heading(Int, Array[Inline])
  Paragraph(Array[Inline])
  Blockquote(Array[Block])
  CodeBlock(String, String)
  List(Bool, Array[Array[Block]])
}

pub(all) struct Document {
  blocks : Array[Block]
}
