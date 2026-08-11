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
pub fn escape_html(s : String) -> String {
  let mut res = ""
  let mut start = 0
  for i = 0; i < s.length(); i = i + 1 {
    let ch = s[i]
    if ch == 60 || ch == 62 || ch == 38 || ch == 34 || ch == 39 {
      if i > start {
        res = res + s[start:i].to_owned()
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
  if s.length() > start {
    res = res + s[start:s.length()].to_owned()
  }
  res
}
