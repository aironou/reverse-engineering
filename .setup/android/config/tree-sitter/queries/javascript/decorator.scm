; @sealed class First {}
; @named("value") class Second {}

(decorator
  (identifier) @decorator.name) @decorator

(decorator
  (call_expression
    function: (identifier) @decorator.name
    arguments: (arguments
      (_)* @decorator.argument) @decorator.arguments)) @decorator
