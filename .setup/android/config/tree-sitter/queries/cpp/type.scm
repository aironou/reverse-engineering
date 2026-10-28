; struct StructType;
; union UnionType;
; enum EnumType;
; typedef int AliasType;
; class ClassType;

(struct_specifier
  "struct" @type.declaration
  name: (type_identifier) @type.name) @type

(union_specifier
  "union" @type.declaration
  name: (type_identifier) @type.name) @type

(enum_specifier
  "enum" @type.declaration
  name: (type_identifier) @type.name) @type

(type_definition
  "type" @type.declaration
  declarator: (type_identifier) @type.alias_name) @type

(class_specifier
  "class" @type.declaration
  name: (type_identifier) @type.name) @type
