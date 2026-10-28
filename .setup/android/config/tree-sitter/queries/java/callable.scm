; class Example { Example(int value) {} void run(int value) {} }

(constructor_declaration
  name: (identifier) @callable.name
  parameters: (formal_parameters
    (_)* @callable.parameter) @callable.parameters) @callable

(method_declaration
  type: (_) @callable.return_type
  name: (identifier) @callable.name
  parameters: (formal_parameters
    (_)* @callable.parameter) @callable.parameters) @callable
