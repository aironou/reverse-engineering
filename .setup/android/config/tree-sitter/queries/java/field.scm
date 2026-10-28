; class Example { private int value = 1; }

(field_declaration
  (modifiers
    _* @field.modifier)? @field.modifiers
  type: (_) @field.type
  declarator: (variable_declarator
    name: (identifier) @field.name
    value: (_)? @field.value)) @field
