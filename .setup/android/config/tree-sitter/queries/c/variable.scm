; int value = 1;
; int *pointer = 0;

(declaration
  type: (_) @variable.type
  declarator: (_
    declarator: (identifier) @variable.name
    value: (_) @variable.value)) @variable

(declaration
  type: (_) @variable.type
  declarator: (_
    declarator: (pointer_declarator
      declarator: (identifier) @variable.name)
    value: (_) @variable.value)) @variable
