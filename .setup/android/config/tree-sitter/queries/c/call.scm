; void login(void) {
;     authenticate(user);
;     log_message("done");
;     logout();
; }

(call_expression
  function: (_) @call.name
  arguments: (argument_list
    (_)* @call.argument) @call.arguments) @call
