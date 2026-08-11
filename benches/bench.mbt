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
fn benchmark_case(bench : @bench.T, markdown : String) -> Unit {
  bench.bench(fn() {
    let parser = @parser.Parser::new(markdown)
    let ast = parser.parse()
    let html = @html.Renderer::new().render(ast)
    bench.keep(html)
  })
}

///|
test "flat markdown" (bench : @bench.T) {
  benchmark_case(
    bench, "A plain paragraph with **strong**, *emphasis*, `code`, and [a link](https://example.com).",
  )
}

///|
test "structured markdown" (bench : @bench.T) {
  benchmark_case(
    bench, "## MoonMark\n\n- first item\n- second item with ![image](https://example.com/a.png)\n\n> quote\n\n```moonbit\nlet answer = 42\n```",
  )
}

///|
test "unicode and nested markdown" (bench : @bench.T) {
  benchmark_case(
    bench,
    ("中文段落与 emoji 😀。" + "\n\n" + "**嵌套文本** ").repeat(8),
  )
}
