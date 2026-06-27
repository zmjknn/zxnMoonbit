pub fn escape_html(s: String) -> String {
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
