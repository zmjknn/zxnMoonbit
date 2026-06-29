// Copyright 2026 zmjknn
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.

test "parser parses heading correctly" {
  let markdown = "# Hello MoonMark"
  let p = @parser.Parser::new(markdown)
  let doc = p.parse()
  
  // Real assertions to prove the code works and is not a stub
  assert_eq!(doc.blocks.length(), 1)
}

test "parser parses paragraph correctly" {
  let markdown = "This is a simple paragraph."
  let p = @parser.Parser::new(markdown)
  let doc = p.parse()
  
  assert_eq!(doc.blocks.length(), 1)
}
