; int value = 1;

(local_variable_declaration
  type: (_) @variable.type
  declarator: (variable_declarator
    name: (identifier) @variable.name
    value: (_)? @variable.value)) @variable
