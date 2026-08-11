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
  if args.length() <= 1 {
    // Default Demo Mode
    let demo = "## MoonMark\n一个纯 MoonBit 实现的解析器！"
    let parser = @parser.Parser::new(demo)
    let ast = parser.parse()
    let html = @html.Renderer::new().render(ast)
    println(html)
    return
  }

  let first = args[1]
  if first == "-h" || first == "--help" {
    print_help()
    return
  }

  if first == "--dir" || first == "-d" {
    if args.length() < 3 {
      println("Error: --dir requires an input directory path.")
      return
    }
    let input_dir = args[2]
    let mut output_dir = "dist"
    let mut i = 3
    while i < args.length() {
      if (args[i] == "-o" || args[i] == "--out-dir") && i + 1 < args.length() {
        output_dir = args[i + 1]
        i = i + 2
      } else {
        i = i + 1
      }
    }
    convert_directory(input_dir, output_dir)
    return
  }

  if first == "--batch" || first == "-b" {
    let files = []
    let mut output_dir = "dist"
    let mut i = 2
    while i < args.length() {
      if (args[i] == "-o" || args[i] == "--out-dir") && i + 1 < args.length() {
        output_dir = args[i + 1]
        i = i + 2
      } else {
        files.push(args[i])
        i = i + 1
      }
    }
    convert_files(files, output_dir)
    return
  }

  // Single file conversion mode
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

  convert_single_file(input_file, output_file)
}

///|
fn convert_single_file(input_file : String, output_file : String?) -> Unit {
  try {
    let markdown = @fs.read_file_to_string(input_file)
    let parser = @parser.Parser::new(markdown)
    let ast = parser.parse()
    let html = @html.Renderer::new().render(ast)

    match output_file {
      Some(out_path) => {
        ensure_parent_dir(out_path)
        @fs.write_string_to_file(out_path, html)
        println("Successfully converted \{input_file} -> \{out_path}")
      }
      None => println(html)
    }
  } catch {
    _ => println("Error: Failed to read '\{input_file}' or write output.")
  }
}

///|
fn convert_files(files : Array[String], output_dir : String) -> Unit {
  if files.length() == 0 {
    println("Error: No files specified for batch conversion.")
    return
  }
  ensure_dir_exists(output_dir)
  for i = 0; i < files.length(); i = i + 1 {
    let file = files[i]
    let filename = get_filename(file)
    let out_path = @path.output_path(output_dir, "", filename)
    convert_single_file(file, Some(out_path))
  }
}

///|
fn convert_directory(input_dir : String, output_dir : String) -> Unit {
  convert_directory_recursive(input_dir, output_dir, "") catch {
    _ => println("Error: Failed to read directory '\{input_dir}'.")
  }
}

///|
fn convert_directory_recursive(
  input_dir : String,
  output_dir : String,
  relative_dir : String,
) -> Unit raise {
  let entries = @fs.read_dir(input_dir)
  for i = 0; i < entries.length(); i = i + 1 {
    let entry = entries[i]
    let input_path = input_dir + "/" + entry
    if @fs.is_dir(input_path) {
      let child_relative = if relative_dir.length() == 0 {
        entry
      } else {
        relative_dir + "/" + entry
      }
      convert_directory_recursive(input_path, output_dir, child_relative)
    } else if entry.has_suffix(".md") || entry.has_suffix(".markdown") {
      convert_single_file(
        input_path,
        Some(@path.output_path(output_dir, relative_dir, entry)),
      )
    }
  }
}

///|
fn ensure_dir_exists(dir_path : String) -> Unit {
  if !@fs.path_exists(dir_path) {
    @fs.create_dir(dir_path) catch {
      _ => ()
    }
  }
}

///|
fn ensure_parent_dir(file_path : String) -> Unit {
  let mut last_slash = -1
  for i = 0; i < file_path.length(); i = i + 1 {
    let ch = file_path[i]
    if ch == 47 || ch == 92 { // '/' or '\'
      last_slash = i
    }
  }
  if last_slash > 0 {
    let parent = file_path[0:last_slash].to_owned()
    ensure_dir_exists(parent)
  }
}

///|
fn get_filename(file_path : String) -> String {
  let mut last_slash = -1
  for i = 0; i < file_path.length(); i = i + 1 {
    let ch = file_path[i]
    if ch == 47 || ch == 92 {
      last_slash = i
    }
  }
  if last_slash >= 0 && last_slash + 1 < file_path.length() {
    file_path[last_slash + 1:file_path.length()].to_owned()
  } else {
    file_path
  }
}

///|
fn print_help() -> Unit {
  println("MoonMark CLI - High-Performance Markdown to HTML Converter")
  println("")
  println("Usage:")
  println("  1. Demo mode:")
  println("     moon run src/cli")
  println("  2. Single file conversion:")
  println("     moon run src/cli -- <input_file> [-o <output_file>]")
  println("  3. Multi-file batch conversion:")
  println("     moon run src/cli -- --batch <f1.md> <f2.md> ... [-o <out_dir>]")
  println("  4. Directory batch conversion:")
  println("     moon run src/cli -- --dir <input_dir> [-o <out_dir>]")
  println("  5. Help:")
  println("     moon run src/cli -- -h | --help")
}
