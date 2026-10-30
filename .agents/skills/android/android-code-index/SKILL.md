---
name: android-code-index
description: |
    inspect the decompiled APK directory, parse supported source files and
    extract structural information. use when need to extract structural
    information from decompiled APK.
---

# android code index

## input

to index a code, user should define the path to directory of decompile d APK
code, also known as `decompiled_code_dir`.

`decompiled_code_dir` should look like `projects/android/{{package_name}}
/artifacts/apk/decompiled/{{APK file name}}`.

## flow

### query

to index code it is necessary to run tree-sitter query on decompiled code. using
`terminal`, run the command:

```shell
make android:tree-sitter {{decompiled_code_dir}}
```

set `output` with command result.

### captures

consider the capture result below:

```
/projects/android/example/artifacts/apk/decompiled/example-base.apk/sources/example
  pattern: 13
    capture: 39 - package, start: (0, 0), end: (0, 27), text: `package androidx.core.view;`
    capture: 38 - package.name, start: (0, 8), end: (0, 26), text: `androidx.core.view`
  pattern: 17
    capture: type, start: (3, 0), end: (5, 1)
    capture: 44 - type.name, start: (3, 17), end: (3, 45), text: `OnReceiveContentViewBehavior`
  pattern: 5
    capture: 13 - callable, start: (4, 4), end: (4, 76), text: `ContentInfoCompat onReceiveContent(`
    capture: 14 - callable.return_type, start: (4, 4), end: (4, 21), text: `ContentInfoCompat`
    capture: 10 - callable.name, start: (4, 22), end: (4, 38), text: `onReceiveContent`
    capture: 12 - callable.parameters, start: (4, 38), end: (4, 75), text: `(ContentInfoCompat contentInfoCompat)`
    capture: 11 - callable.parameter, start: (4, 39), end: (4, 74), text: `ContentInfoCompat contentInfoCompat`
```

the first line is the `full_filename`. set `filename` as `full_filename` without
`decompiled_code_dir` prefix.

every pattern contains `capture_key`, `start_line`, `start_column`,
`end_column`, `end_line` and `value`, e.g:

```
pattern: 0
  capture: {{capture_key}}, start: ({{start_line}}, {{start_column}}), end: ({{end_line}}, {{end_column}}), text: `{{value}}`
  capture: 0 - {{capture_key}}, start: ({{start_line}}, {{start_column}}), end: ({{end_line}}, {{end_column}}), text: `{{value}}`
```

every time you set a new object with the pattern values, include the values
as below:

```json
{
    "file": "file:{{full_filename}}",
    "range": {
        "start": "{{start_line}}:{{start_column}}",
        "end": "{{end_line}}:{{end_column}}"
    }
}
```

while setting new objects with the pattern values, merge the objects with
the same `id`.

#### annotation

for each pattern with `annotation` capture key, create a new `annotation` with
properties as below:

```json
{
    "id": "annotation:{{filename}}@{{start}}",
    "name": "{{annotation.name}}",
    "arguments": "{{list of annotation.argument}}",
    "target": "{{target}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `annotation.name`.

where `target` is the `id` of the first non-`annotation` element below the
`annotation` in the same file. compare positions by line using the `start`
encoded after `@` in each element's `id`.

#### assignment

for each pattern with `assignment` capture key, create a new `assignment` with
properties as below:

```json
{
    "id": "assignment:{{filename}}@{{start}}",
    "target": "{{assignment.target}}",
    "value": "{{assignment.value}}",
    "scope": "{{scope}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `assignment.target`.

where `scope` is the `id` of the closest indexed element that contains the
`assignment` in the same file and is not a condition. compare positions by
line using the `range.start` and `range.end` in each element.

#### attribute

for each pattern with `attribute` capture key, create a new `attribute` with
properties as below:

```json
{
    "id": "attribute:{{filename}}@{{start}}",
    "name": "{{attribute.name}}",
    "arguments": "{{list of attribute.argument}}",
    "target": "{{target}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `attribute.name`.

where `target` is the `id` of the first non-`attribute` element below the
`attribute` in the same file. compare positions by line using the `start`
encoded after `@` in each element's `id`.

#### call

for each pattern with `call` capture key, create a new `call` with properties
as below:

```json
{
    "id": "call:{{filename}}@{{start}}",
    "function": "{{call.name}}",
    "object": "{{call.object}}",
    "arguments": "{{list of call.argument}}",
    "scope": "{{scope}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `call.name`.

where `scope` is the `id` of the closest indexed element that contains the
`call` in the same file and is not a condition, variable or return. compare
positions by line using the `range.start` and `range.end` in each element.

#### callable

for each pattern with `callable` capture key, create a new `callable` with
properties as below:

```json
{
    "id": "callable:{{filename}}@{{start}}",
    "name": "{{callable.name}}",
    "qualified_name": "{{callable qualified name}}",
    "return_type": "{{callable.return_type}}",
    "parameters": "{{list of callable.parameter}}",
    "scope": "{{scope}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `callable.name`.

where `scope` is the `id` of the closest indexed element that contains the
`callable` in the same file and is not a condition. compare positions by line
using the `range.start` and `range.end` in each element.

set `qualified_name` by joining the enclosing package namespace, the names of
any enclosing types from outermost to innermost, and `callable.name`, separated
by `.`. use the `package.namespace` from the package declaration in the same
file and the enclosing types identified through `scope`. omit a missing package
namespace.

#### condition

for each pattern with `condition` capture key, create a new `condition` with
properties as below:

```json
{
    "id": "condition:{{filename}}@{{start}}",
    "expression": "{{condition.expression}}",
    "subject": "{{condition.subject}}",
    "body": "{{condition.body}}",
    "consequence": "{{condition.consequence}}",
    "alternative": "{{condition.alternative}}",
    "scope": "{{scope}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `condition.expression`.

where `scope` is the `id` of the closest indexed element that contains the
`condition` in the same file and is not a condition. compare positions by line
using the `range.start` and `range.end` in each element.

#### decorator

for each pattern with `decorator` capture key, create a new `decorator` with
properties as below:

```json
{
    "id": "decorator:{{filename}}@{{start}}",
    "name": "{{decorator.name}}",
    "arguments": "{{list of decorator.argument}}",
    "target": "{{target}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `decorator.name`.

where `target` is the `id` of the first non-`decorator` element below the
`decorator` in the same file. compare positions by line using the `start`
encoded after `@` in each element's `id`.

#### external

for each pattern with `external` capture key, create a new `external` with
properties as below:

```json
{
    "id": "external:{{filename}}@{{start}}",
    "name": "{{external.name}}",
    "qualified_name": "{{external qualified name}}",
    "return_type": "{{external.return_type}}",
    "parameters": "{{list of external.parameter}}",
    "scope": "{{scope}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `external.name`.

where `scope` is the `id` of the closest indexed element that contains the
`external` in the same file and is not a condition. compare positions by line
using the `range.start` and `range.end` in each element.

set `qualified_name` by joining the package namespace, enclosing type names
from outermost to innermost, and `external.name`, separated by `.`. derive the
package namespace from the package declaration in the same file and the
enclosing types through `scope`. omit a missing package namespace.

#### field

for each pattern with `field` capture key, create a new `field` with properties
as below:

```json
{
    "id": "field:{{filename}}@{{start}}",
    "name": "{{field.name}}",
    "qualified_name": "{{field qualified name}}",
    "type": "{{field.type}}",
    "value": "{{field.value}}",
    "modifiers": "{{list of field.modifier}}",
    "scope": "{{scope}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `field.name`.

where `scope` is the `id` of the closest indexed element that contains the
`field` in the same file and is not a condition. compare positions by line
using the `range.start` and `range.end` in each element.

set `qualified_name` by joining the package namespace, enclosing type names
from outermost to innermost, and `field.name`, separated by `.`. derive the
package namespace from the package declaration in the same file and the
enclosing types through `scope`. omit a missing package namespace.

#### import

for each pattern with `import` capture key, create a new `import` with
properties as below:

```json
{
    "id": "import:{{filename}}@{{start}}",
    "name": "{{import.name}}",
    "path": "{{import.path}}",
    "source": "{{import.source}}",
    "type": "{{import.type}}",
    "function": "{{import.function}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `import.name`.

#### native

for each pattern with `native` capture key, create a new `native` with
properties as below:

```json
{
    "id": "native:{{filename}}@{{start}}",
    "name": "{{native.name}}",
    "qualified_name": "{{native qualified name}}",
    "return_type": "{{native.return_type}}",
    "parameters": "{{list of native.parameter}}",
    "scope": "{{scope}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `native.name`.

where `scope` is the `id` of the closest indexed element that contains the
`native` in the same file. compare positions using the `range.start` and
`range.end` in each element.

set `qualified_name` by joining the package namespace, enclosing type names
from outermost to innermost, and `native.name`, separated by `.`. derive the
package namespace from the package declaration in the same file and the
enclosing types through `scope`. omit a missing package namespace.

#### native load

for each pattern with `native_load` capture key, create a new `native_load`
with properties as below:

```json
{
    "id": "native_load:{{filename}}@{{start}}",
    "function": "{{native_load.function}}",
    "method": "{{native_load.method}}",
    "object": "{{native_load.object}}",
    "values": "{{list of native_load.value}}",
    "scope": "{{scope}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `native_load`.

where `scope` is the `id` of the closest indexed element that contains the
`native_load` in the same file. compare positions using the `range.start` and
`range.end` in each element.

#### package

for each pattern with `package` capture key, create a new `package` with
properties as below:

```json
{
    "id": "package:{{filename}}@{{start}}",
    "name": "{{package.name}}",
    "namespace": "{{package.namespace}}",
    "qualified_name": "{{package.namespace}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `package.name`.

set `qualified_name` to the package namespace captured by `package.namespace`.

read the package namespace from the package declaration in the same source
file. Do not infer it from the APK application ID, directory path, or manifest.
If a declaration exists, `package.namespace` and `package.qualified_name` must
contain its namespace. An empty namespace is valid only when the source file
has no package declaration.

#### return

for each pattern with `return` capture key, create a new `return` with
properties as below:

```json
{
    "id": "return:{{filename}}@{{start}}",
    "label": "{{return.label}}",
    "value": "{{return.value}}",
    "scope": "{{scope}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `return`.

where `scope` is the `id` of the closest indexed element that contains the
`return` in the same file and is a `callable`. compare positions using the
`range.start` and `range.end` in each element.

#### string

for each pattern with `string` capture key, create a new `string` with
properties as below:

```json
{
    "id": "string:{{filename}}@{{start}}",
    "value": "{{string.value}}",
    "scope": "{{scope}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `string.value`.

where `scope` is the `id` of the closest indexed element that contains the
`string` in the same file. compare positions using the `range.start` and
`range.end` in each element.

#### type

for each pattern with `type` capture key, create a new `type` with properties
as below:

```json
{
    "id": "type:{{filename}}@{{start}}",
    "name": "{{type.name}}",
    "qualified_name": "{{type qualified name}}",
    "alias_name": "{{type.alias_name}}",
    "scope": "{{scope}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `type.name`.

where `scope` is the `id` of the closest indexed element that contains the
`type` in the same file. compare positions using the `range.start` and
`range.end` in each element. if none exists, set `scope` to `null`.

set `qualified_name` by joining the package namespace, any enclosing type
names from outermost to innermost, and `type.name`, separated by `.`. get the
package namespace from the package declaration in the same file and enclosing
type names by following the type's `scope` chain. omit a missing package
namespace.

#### variable

for each pattern with `variable` capture key, create a new `variable` with
properties as below:

```json
{
    "id": "variable:{{filename}}@{{start}}",
    "name": "{{variable.name}}",
    "type": "{{variable.type}}",
    "value": "{{variable.value}}",
    "scope": "{{scope}}"
}
```

where `start` is `{{start_line}}:{{start_column}}` of `variable.name`.

where `scope` is the `id` of the closest indexed element that contains the
`variable` in the same file. compare positions using the `range.start` and
`range.end` in each element. if none exists, set `scope` to `null`.

### generate index file

set `APK file name` to the basename of `decompiled_code_dir`. create a new JSON
file at `projects/android/{{package_name}}/artifacts/analysis/index
/{{APK file name}}.json`, with the values as below:

build the JSON from the current tree-sitter capture result. When the user asks
for a new index, do not reuse, copy, or merely reserialize an existing index.
Before writing, derive package namespaces from their source declarations, then
derive each type, callable, field, external, and native `qualified_name` from
that namespace and its enclosing types. Preserve an empty namespace only for a
file with no package declaration.

```json
{
    "annotations": "{{annotation list}}",
    "assignments": "{{assignment list}}",
    "attributes": "{{attribute list}}",
    "calls": "{{call list}}",
    "callables": "{{callable list}}",
    "conditions": "{{condition list}}",
    "decorators": "{{decorator list}}",
    "externals": "{{external list}}",
    "fields": "{{field list}}",
    "imports": "{{import list}}",
    "natives": "{{native list}}",
    "natives_loads": "{{natives_load list}}",
    "packages": "{{package list}}",
    "returns": "{{return list}}",
    "strings": "{{string list}}",
    "types": "{{type list}}",
    "variables": "{{variable list}}"
}
```

## verification

after processing this skill flow:

- confirm that `projects/android/{{package_name}}/artifacts/analysis/index` 
  exists;
- confirm that `projects/android/{{package_name}}/artifacts/analysis/index
  /{{APK file name}}.json` exists;
- confirm that `projects/android/{{package_name}}/artifacts/analysis/index
  /{{APK file name}}.json` is the only file created by this skill.
- confirm that each indexed package with a source package declaration has a
  non-empty `namespace`, and that qualified names include that namespace.
