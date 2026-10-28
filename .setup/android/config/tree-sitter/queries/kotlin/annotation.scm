; @Deprecated
; @Suppress("value")

(annotation
  (user_type) @annotation.name) @annotation

(annotation
  (constructor_invocation
      (user_type) @annotation.name
        (value_arguments
          (value_argument)* @annotation.argument) @annotation.arguments)) @annotation
