; void login() {
;     service.authenticate(user);
;     Logger::log("done");
;     logout();
; }

(call_expression
  function: [
    (identifier) @call.name
    (field_expression
      argument: (_) @call.object
      field: (_) @call.name)
    (qualified_identifier
      scope: (_) @call.object
      name: (_) @call.name)
  ]
  arguments: (argument_list
    (_)* @call.argument) @call.arguments) @call
