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
\npub fn escape_html(s: String) -> String {
  let mut res = ""
  for i = 0; i < s.length(); i = i + 1 {
    match s[i] {
      '<' => res = res + "&lt;"
      '>' => res = res + "&gt;"
      '&' => res = res + "&amp;"
      '"' => res = res + "&quot;"
      '\'' => res = res + "&#39;"
      c => res = res + c.to_string()
    }
  }
  res
}
