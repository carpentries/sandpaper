# prefixed episodes can be reverted

    Code
      strip_prefix(tmp, write = FALSE)
    Message
      i Stripped prefixes
      1. '01-introduction.Rmd' -> 'introduction.Rmd'
      2. '02-first-markdown.md' -> 'first-markdown.md'
      3. '03-안녕-😭-kitty.Rmd' -> '안녕-😭-kitty.Rmd'
      --------------------------------------------------------------------------------
      i To save this configuration, use
      
      strip_prefix(path = tmp, write = TRUE)

---

    Code
      strip_prefix(tmp, write = FALSE)
    Message
      i No prefix detected... nothing to do
    Output
      [1] "introduction.Rmd"  "first-markdown.md" "안녕-😭-kitty.Rmd"

