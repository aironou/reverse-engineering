; dlopen("libexample.so");

(
  (call_expression
    function: (identifier) @native_load.function
      arguments: (argument_list
        (string_literal)* @native_load.value) @native_load.values) @native_load
  (#eq? @native_load.function "dlopen")
)
