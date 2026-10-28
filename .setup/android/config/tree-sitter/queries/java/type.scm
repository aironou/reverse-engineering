; class ClassType {}
; interface InterfaceType {}
; enum EnumType {}
; record RecordType() {}
; @interface AnnotationType {}

(class_declaration
  "class" @type.declaration
  name: (identifier) @type.name) @type

(interface_declaration
  "interface" @type.declaration
  name: (identifier) @type.name) @type

(enum_declaration
  "enum" @type.declaration
  name: (identifier) @type.name) @type

(record_declaration
  "record" @type.declaration
  name: (identifier) @type.name) @type

(annotation_type_declaration
  "@interface" @type.declaration
  name: (identifier) @type.name) @type
