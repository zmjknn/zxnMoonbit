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
pub fn escape_html(sv : StringView) -> String {
  let mut res = ""
  let mut start = 0
  let len = sv.length()
  for i = 0; i < len; i = i + 1 {
    let ch = sv[i]
    if ch == 60 || ch == 62 || ch == 38 || ch == 34 || ch == 39 {
      if i > start {
        res = res + sv[start:i].to_owned()
      }
      match ch {
        60 => res = res + "&lt;"
        62 => res = res + "&gt;"
        38 => res = res + "&amp;"
        34 => res = res + "&quot;"
        39 => res = res + "&#39;"
        _ => ()
      }
      start = i + 1
    }
  }
  if len > start {
    res = res + sv[start:len].to_owned()
  }
  res
}
