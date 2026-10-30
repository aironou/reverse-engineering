---
name: android-reverse-engineering-orchestration
description: |
    android reverse engineering orchestration. use when user asks for reverse
    engineering an android app.
---

# android reverse engineering orchestration

## input

to reverse engineering an android app, user should define `package_name` as
known as android application ID at play store.

## flow

### download APK file

check APK files of `package_name` in host. if files does not exist, then
download `package_name`. else, ask if user wants to download `package_name`
again. **only download `package_name` again when user agree to repeat the
download.**

**do not advance without an APK file of `package_name`.**

### analyze APK file

before executing some action, check if it was already executed. if it was not
executed, then execute action. else, ask if user wants to execute the action
again. **only execute action again if user asked for it.**

consider the actions below:

| action                  | depends_on                                  |
|-------------------------|---------------------------------------------|
| `android-apk-inspect`   |                                             |
| `android-apk-decode`    |                                             |
| `android-apk-decompile` |                                             |
| `android-code-index`    | `android-apk-decompile`                     |
| `android-code-map`      | `android-apk-inspect`, `android-code-index` |

for each APK file of `package_name`:

1. run actions in parallel;
2. run each action only after its dependencies are successfully run.

**do not advance while some action is running.**

### clean

using `terminal`, run the command:

```shell
make destroy android -B
```