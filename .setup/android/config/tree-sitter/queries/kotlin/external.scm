; external fun read(descriptor: Int): String

(function_declaration
  (modifiers (function_modifier "external"))
  (simple_identifier) @external.name
  (function_value_parameters
    (parameter)* @external.parameter) @external.parameters
  (user_type
    (type_identifier) @external.return_type)) @external
