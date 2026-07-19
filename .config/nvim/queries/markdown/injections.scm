; extends

; ```{r} / ```{r, echo=TRUE} → 注入 R
(fenced_code_block
  (info_string) @info
  (code_fence_content) @injection.content
  (#match? @info "^\\{r[ ,}]")
  (#set! injection.language "r"))
