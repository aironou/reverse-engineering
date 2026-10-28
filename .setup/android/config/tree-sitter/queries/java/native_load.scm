; System.load("/tmp/libexample.so");

(
(method_invocation
  object: (identifier) @native_load.object
  name: (identifier) @native_load.method
  arguments: (argument_list
      (_)* @native_load.value) @native_load.values) @native_load
  (#eq? @native_load.object "System")
  (#eq? @native_load.method "load")
)
