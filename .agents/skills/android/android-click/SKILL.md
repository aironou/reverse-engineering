---
name: android-click
description: |
    simulate a click through the emulator. use when need to click on screen.
---

# android click

## requirements

- `ADB shell` available

## input

to simulate a click, user should define the coordinates `{{x}}` and `{{y}}`
or define the element to be clicked, using element description or text.

## flow

### search elements at screen

if the instruction is to click on an element, search for the element. when an
element is found, coordinates are calculated using node bounds, i.e.:

```xml
<node bounds="[{{initial_x}},{{initial_y}}][{{final_x}},{{final_y}}]" />
```

where `{{initial_x}}` and `{{initial_y}}` are the `top left corner` coordinates
and `{{final_x}}` and `{{final_y}}` are the `bottom right corner` coordinates.

`{{x}}` is equal to `({{initial_x}} + {{final_x}}) / 2` and `{{y}}` is equal to
`({{initial_y}} + {{final_y}}) / 2`.

### click

using `ADB shell`, run the command:

```shell
input tap {{x}} {{y}}
```