; fun getHost(): String {
;     logout()
;     return "api.example.com"
; }
;
; fun process() {
;     return
;     return@label
;     return@label result
; }

(jump_expression
  "return"
  (_)? @return.value) @return

(jump_expression
  "return@"
  (label) @return.label
  (_)? @return.value) @return
