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
pub fn replace_ext_html(filename : String) -> String {
  if filename.has_suffix(".md") {
    filename[0:filename.length() - 3].to_owned() + ".html"
  } else if filename.has_suffix(".markdown") {
    filename[0:filename.length() - 9].to_owned() + ".html"
  } else {
    filename + ".html"
  }
}

///|
pub fn output_path(
  output_dir : String,
  relative_dir : String,
  filename : String,
) -> String {
  let output_name = replace_ext_html(filename)
  if relative_dir.length() == 0 {
    output_dir + "/" + output_name
  } else {
    output_dir + "/" + relative_dir + "/" + output_name
  }
}
