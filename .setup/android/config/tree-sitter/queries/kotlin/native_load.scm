; class Example { init { System.loadLibrary("example") } }

(
  (anonymous_initializer
    (statements
        (call_expression
            (navigation_expression) @native_load.method
              (call_suffix
                (value_arguments
                    (value_argument)* @native_load.value) @native_load.values)))) @native_load
  (#eq? @native_load.method "System.loadLibrary")
)
