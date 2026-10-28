; function run(value) {}
; class Example { run(value) {} }

(function_declaration
  name: (identifier) @callable.name
  parameters: (formal_parameters
    (_)* @callable.parameter) @callable.parameters) @callable

(method_definition
  name: (property_identifier) @callable.name
  parameters: (formal_parameters
    (_)* @callable.parameter) @callable.parameters) @callable
