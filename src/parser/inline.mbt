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

pub fn parse_inline(text : String) -> Array[@ast.Inline] {
  let inlines = []
  let mut i = 0
  let len = text.length()
  
  while i < len {
    let ch = text[i]
    
    // Code span: `code`
    if ch == '`' {
      let mut j = i + 1
      while j < len && text[j] != '`' {
        j = j + 1
      }
      if j < len {
        let code = text[i + 1 : j].to_owned()
        inlines.push(@ast.CodeSpan(code))
        i = j + 1
        continue
      }
    }
    
    // Strong / Emph: **bold** or *italic*
    if ch == '*' {
      let is_strong = i + 1 < len && text[i + 1] == '*'
      if is_strong {
        let mut j = i + 2
        while j + 1 < len && !(text[j] == '*' && text[j + 1] == '*') {
          j = j + 1
        }
        if j + 1 < len {
          let inner_text = text[i + 2 : j].to_owned()
          inlines.push(@ast.Strong(parse_inline(inner_text)))
          i = j + 2
          continue
        }
      } else {
        let mut j = i + 1
        while j < len && text[j] != '*' {
          j = j + 1
        }
        if j < len {
          let inner_text = text[i + 1 : j].to_owned()
          inlines.push(@ast.Emph(parse_inline(inner_text)))
          i = j + 1
          continue
        }
      }
    }
    
    // Link: [text](url)
    if ch == '[' {
      let mut j = i + 1
      while j < len && text[j] != ']' {
        j = j + 1
      }
      if j + 1 < len && text[j + 1] == '(' {
        let mut k = j + 2
        while k < len && text[k] != ')' {
          k = k + 1
        }
        if k < len {
          let link_text = text[i + 1 : j].to_owned()
          let link_url = text[j + 2 : k].to_owned()
          inlines.push(@ast.Link(link_url, parse_inline(link_text)))
          i = k + 1
          continue
        }
      }
    }
    
    // Normal Text
    let mut j = i
    while j < len {
      let next_ch = text[j]
      if next_ch == '`' || next_ch == '*' || next_ch == '[' {
        break
      }
      j = j + 1
    }
    if j > i {
      inlines.push(@ast.Text(text[i : j].to_owned()))
      i = j
    } else {
      inlines.push(@ast.Text(ch.to_string()))
      i = i + 1
    }
  }
  
  inlines
}
