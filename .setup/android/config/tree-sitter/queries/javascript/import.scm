; import "example";
; require("example");

(import_statement
  source: (string) @import.source) @import

(
  (call_expression
    function: (identifier) @import.function
    arguments: (arguments (string) @import.source))
  (#eq? @import.function "require")
) @import
