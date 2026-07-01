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

test "parser heading" {
  let p = Parser::new("# Heading 1\n## Heading 2")
  let doc = p.parse()
  assert_eq(doc.blocks.length(), 2)
}

test "parser paragraph and inlines" {
  let p = Parser::new("This is **bold** and *italic* and `code` and [link](url).")
  let doc = p.parse()
  assert_eq(doc.blocks.length(), 1)
}

test "parser code block" {
  let p = Parser::new("```moonbit\nlet a = 1\n```")
  let doc = p.parse()
  assert_eq(doc.blocks.length(), 1)
}

test "parser blockquote" {
  let p = Parser::new("> This is a blockquote\n> containing a paragraph.")
  let doc = p.parse()
  assert_eq(doc.blocks.length(), 1)
}

test "parser list" {
  let p = Parser::new("- Item 1\n- Item 2\n- Item 3")
  let doc = p.parse()
  assert_eq(doc.blocks.length(), 1)
}
