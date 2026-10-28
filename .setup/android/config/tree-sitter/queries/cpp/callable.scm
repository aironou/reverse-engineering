; void run(int value) {}

(function_definition
  declarator: (function_declarator
    declarator: (identifier) @callable.name
    parameters: (parameter_list
      (_)* @callable.parameter) @callable.parameters)) @callable
