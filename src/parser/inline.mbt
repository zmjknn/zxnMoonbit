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
pub fn parse_inline(
  text : StringView,
  start_pos : @ast.Position,
) -> Array[@ast.Inline] {
  let inlines = []
  let mut i = 0
  let len = text.length()

  let mut line = start_pos.line
  let mut col = start_pos.column
  let mut offset = start_pos.offset

  fn current_pos() -> @ast.Position {
    { line, column: col, offset }
  }

  fn advance_range(start_idx : Int, end_idx : Int) {
    for idx = start_idx; idx < end_idx; idx = idx + 1 {
      let ch = text[idx]
      if ch == 10 { // '\n'
        line = line + 1
        col = 1
      } else {
        col = col + 1
      }
      offset = offset + 1
    }
  }

  while i < len {
    let ch = text[i]

    // Image: ![alt](url)
    if ch == 33 && i + 1 < len && text[i + 1] == 91 { // '!' is 33, '[' is 91
      let start_pos_span = current_pos()
      let mut j = i + 2
      let mut bracket_count = 1
      while j < len {
        if text[j] == 91 { // '['
          bracket_count = bracket_count + 1
        } else if text[j] == 93 { // ']'
          bracket_count = bracket_count - 1
          if bracket_count == 0 {
            break
          }
        }
        j = j + 1
      }
      if j + 1 < len && text[j + 1] == 40 { // '(' is 40
        let mut k = j + 2
        let mut paren_count = 1
        while k < len {
          if text[k] == 40 { // '('
            paren_count = paren_count + 1
          } else if text[k] == 41 { // ')'
            paren_count = paren_count - 1
            if paren_count == 0 {
              break
            }
          }
          k = k + 1
        }
        if k < len {
          let alt = text[i + 2:j]
          let url = text[j + 2:k]

          advance_range(i, k + 1)
          let end_pos_span = current_pos()
          let span = @ast.Span::{ start: start_pos_span, end: end_pos_span }
          inlines.push(@ast.Image(span, url, alt))
          i = k + 1
          continue
        }
      }
    }

    // Code span: `code`
    if ch == 96 { // '`' is 96
      let start_pos_span = current_pos()
      let mut j = i + 1
      while j < len && text[j] != 96 {
        j = j + 1
      }
      if j < len {
        let code = text[i + 1:j]
        advance_range(i, j + 1)
        let end_pos_span = current_pos()
        let span = @ast.Span::{ start: start_pos_span, end: end_pos_span }
        inlines.push(@ast.CodeSpan(span, code))
        i = j + 1
        continue
      }
    }

    // Strong / Emph: **bold** or *italic*
    if ch == 42 { // '*' is 42
      let is_strong = i + 1 < len && text[i + 1] == 42
      if is_strong {
        let start_pos_span = current_pos()
        let mut j = i + 2
        while j + 1 < len && !(text[j] == 42 && text[j + 1] == 42) {
          j = j + 1
        }
        if j + 1 < len {
          let inner_text = text[i + 2:j]

          // Advance over standard prefix `**`
          advance_range(i, i + 2)
          let inner_start_pos = current_pos()

          // Parse inner inlines
          let inner_inlines = parse_inline(inner_text, inner_start_pos)

          // Advance over inner text and closing `**`
          advance_range(i + 2, j + 2)
          let end_pos_span = current_pos()
          let span = @ast.Span::{ start: start_pos_span, end: end_pos_span }
          inlines.push(@ast.Strong(span, inner_inlines))
          i = j + 2
          continue
        }
      } else {
        let start_pos_span = current_pos()
        let mut j = i + 1
        while j < len && text[j] != 42 {
          j = j + 1
        }
        if j < len {
          let inner_text = text[i + 1:j]

          // Advance over standard prefix `*`
          advance_range(i, i + 1)
          let inner_start_pos = current_pos()

          // Parse inner inlines
          let inner_inlines = parse_inline(inner_text, inner_start_pos)

          // Advance over inner text and closing `*`
          advance_range(i + 1, j + 1)
          let end_pos_span = current_pos()
          let span = @ast.Span::{ start: start_pos_span, end: end_pos_span }
          inlines.push(@ast.Emph(span, inner_inlines))
          i = j + 1
          continue
        }
      }
    }

    // Link: [text](url)
    if ch == 91 { // '[' is 91
      let start_pos_span = current_pos()
      let mut j = i + 1
      let mut bracket_count = 1
      while j < len {
        if text[j] == 91 { // '['
          bracket_count = bracket_count + 1
        } else if text[j] == 93 { // ']'
          bracket_count = bracket_count - 1
          if bracket_count == 0 {
            break
          }
        }
        j = j + 1
      }
      if j + 1 < len && text[j + 1] == 40 { // '(' is 40
        let mut k = j + 2
        let mut paren_count = 1
        while k < len {
          if text[k] == 40 { // '('
            paren_count = paren_count + 1
          } else if text[k] == 41 { // ')'
            paren_count = paren_count - 1
            if paren_count == 0 {
              break
            }
          }
          k = k + 1
        }
        if k < len {
          let link_text = text[i + 1:j]
          let link_url = text[j + 2:k]

          // Advance over `[`
          advance_range(i, i + 1)
          let inner_start_pos = current_pos()

          // Parse inner inlines
          let inner_inlines = parse_inline(link_text, inner_start_pos)

          // Advance over inner text and closing `](url)`
          advance_range(i + 1, k + 1)
          let end_pos_span = current_pos()
          let span = @ast.Span::{ start: start_pos_span, end: end_pos_span }
          inlines.push(@ast.Link(span, link_url, inner_inlines))
          i = k + 1
          continue
        }
      }
    }

    // Normal Text
    let start_pos_span = current_pos()
    let mut j = i
    while j < len {
      let next_ch = text[j]
      // Check for delimiters: '`' (96), '*' (42), '[' (91), '!' (33) followed by '[' (91)
      if next_ch == 96 || next_ch == 42 || next_ch == 91 {
        break
      }
      if next_ch == 33 && j + 1 < len && text[j + 1] == 91 {
        break
      }
      j = j + 1
    }
    if j > i {
      let content = text[i:j]
      advance_range(i, j)
      let end_pos_span = current_pos()
      let span = @ast.Span::{ start: start_pos_span, end: end_pos_span }
      inlines.push(@ast.Text(span, content))
      i = j
    } else {
      let ch_fallback = text[i]
      let step = if ch_fallback >= 55296 && ch_fallback <= 56319 && i + 1 < len {
        2
      } else {
        1
      }
      let content = text[i:i + step]
      advance_range(i, i + step)
      let end_pos_span = current_pos()
      let span = @ast.Span::{ start: start_pos_span, end: end_pos_span }
      inlines.push(@ast.Text(span, content))
      i = i + step
    }
  }

  inlines
}
