; fun login() {
;     authService.authenticate(user)
;     log("done", 123)
;     logout()
; }

(call_expression
  (navigation_expression
    (simple_identifier) @call.object
    (navigation_suffix (simple_identifier) @call.name))?
  (simple_identifier)? @call.name
  (call_suffix
    (value_arguments (value_argument)* @call.argument) @call.arguments)) @call
