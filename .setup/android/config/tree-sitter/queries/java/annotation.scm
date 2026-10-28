; @Deprecated
; @SuppressWarnings("value")

(marker_annotation
  name: (identifier) @annotation.name) @annotation

(annotation
  name: (identifier) @annotation.name
  arguments: (annotation_argument_list
    (_)* @annotation.argument) @annotation.arguments) @annotation
