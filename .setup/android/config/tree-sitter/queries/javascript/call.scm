; function login() {
;     authService.authenticate(user);
;     log("done", 123);
;     logout();
; }

(call_expression
  function: (identifier)? @call.name
  function: (member_expression
    object: (identifier) @call.object
    property: (property_identifier) @call.name)?
  arguments: (arguments
    (_)* @call.argument) @call.arguments)
