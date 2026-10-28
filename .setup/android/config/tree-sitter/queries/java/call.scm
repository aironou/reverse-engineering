; public void login() {
;     authService.authenticate(user);
;     log("done");
;     logout();
; }

(method_invocation
  object: (identifier)? @call.object
  name: (identifier) @call.name
  arguments: (argument_list
    (_)* @call.argument) @call.arguments) @call
