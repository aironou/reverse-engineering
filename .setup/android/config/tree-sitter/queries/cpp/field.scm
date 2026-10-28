; class Example { int value = 1; };

(field_declaration
  type: (_) @field.type
  declarator: (field_identifier) @field.name
  default_value: (_)? @field.value) @field
