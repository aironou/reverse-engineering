; fun run(value: Int) {}
; class Example { constructor(value: Int) }

(function_declaration
  (simple_identifier) @callable.name
  (function_value_parameters
    (parameter)* @callable.parameter) @callable.parameters) @callable

(secondary_constructor
  (function_value_parameters
    (parameter)* @callable.parameter) @callable.parameters) @callable
