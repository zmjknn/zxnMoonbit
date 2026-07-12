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
test (b : @bench.T) {
  let demo = "## MoonMark\n一个纯 MoonBit 实现的解析器！\n- 列表项 1\n- 列表项 2\n> 引用内容\n`inline code` and **bold** and *italic* and ![图片](url)."
  b.bench(fn() {
    let parser = @parser.Parser::new(demo)
    let ast = parser.parse()
    let html = @html.Renderer::new().render(ast)
    b.keep(html)
  })
}
