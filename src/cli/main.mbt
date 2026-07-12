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
fn main {
  let args = @env.args()
  // args[0] is the executable path
  if args.length() > 1 {
    let first = args[1]
    if first == "-h" || first == "--help" {
      print_help()
      return
    }

    // File conversion mode
    let input_file = first
    let mut output_file : String? = None

    let mut i = 2
    while i < args.length() {
      if args[i] == "-o" && i + 1 < args.length() {
        output_file = Some(args[i + 1])
        i = i + 2
      } else {
        i = i + 1
      }
    }

    try {
      let markdown = @fs.read_file_to_string(input_file)
      let parser = @parser.Parser::new(markdown)
      let ast = parser.parse()
      let html = @html.Renderer::new().render(ast)

      match output_file {
        Some(out_path) => {
          @fs.write_string_to_file(out_path, html)
          println("Successfully converted \{input_file} to \{out_path}")
        }
        None => println(html)
      }
    } catch {
      _ =>
        println("Error: Failed to read file '\{input_file}' or write output.")
    }
  } else {
    // Default Demo Mode (renders normally when run with `moon run src/cli`)
    let demo = "## MoonMark\n一个纯 MoonBit 实现的解析器！"
    let parser = @parser.Parser::new(demo)
    let ast = parser.parse()
    let html = @html.Renderer::new().render(ast)
    println(html)
  }
}

///|
fn print_help() -> Unit {
  println("MoonMark CLI - Markdown to HTML Converter")
  println("Usage:")
  println("  moon run src/cli -- <input_file> [-o <output_file>]")
  println("  moon run src/cli -- -h | --help")
}
