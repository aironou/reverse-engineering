; #include <stdio.h>
; import example;

(preproc_include
  path: (_) @import.path) @import

(
  (declaration
    type: (_) @import.type
    declarator: (identifier) @import.name) @import
  (#eq? @import.type "import")
)