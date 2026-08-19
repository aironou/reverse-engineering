---
name: android-screen-element-search
description: |
    search for an element in android emulator screen. use when need to search 
    for an element.
---

# android screen element search

## requirements

- `ADB shell` available

## input

to search an element, user should define the element to be searched, using
element description or text.

## flow

### search element at screen

to search for an element, save and print the current UI hierarchy to find the
element.

to save and print the current UI hierarchy, using `ADB shell`, run the commands:

```shell
uiautomator dump /data/local/tmp/window_dump.xml
cat /data/local/tmp/window_dump.xml
```

keep the result until the current screen state is understood, but update the
result every time a new search is required.

evaluate attributes in this order: `resource-id`, `text`, `content-desc`, then
`class`, `clickable`, `enabled`, and `bounds`. a non-empty `resource-id` may be
reused during the current run, but **do not persist or assume a `resource-id`
across runs.**

an action candidate must have `clickable="true"` and `enabled="true"`. there
must be exactly one candidate for a role before using its `bounds`.

**do not click if there are zero or multiple candidates and do not select a
node by its position in the hierarchy or by approximate screen coordinates.**