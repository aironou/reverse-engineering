; __attribute__((noreturn))
; __attribute__((aligned(16)))
; __attribute__((section("value")))
; __attribute__((format(printf, 1, 2)))
; [[deprecated]]
; [[deprecated("value")]]
; [[nodiscard("value", 123)]]

(attribute_specifier
  (argument_list
    (identifier)? @attribute.name
    (call_expression
      function: (identifier) @attribute.name
      arguments: (argument_list
        (_)* @attribute.argument)? @attribute.arguments)?)) @attribute

(attribute_declaration
  (attribute
    name: (identifier) @attribute.name
    (argument_list
      (_)* @attribute.argument)? @attribute.arguments)) @attribute
