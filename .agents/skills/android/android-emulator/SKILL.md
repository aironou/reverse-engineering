---
name: android-emulator
description: |
    start ADB shell using android emulator (GUI or headless). use when need to 
    use ADB shell for some action or when user asks to start android emulator or
    ADB shell.
---

# android emulator

## flow

### start ADB shell (headless android emulator)

run the command:

```shell
make android:emulator headless
```

### start ADB shell (GUI android emulator)

run the command:

```shell
make android:emulator
```

### stop ADB shell

using `ADB shell` itself, run the command:

```shell
exit
```

if `ADB shell` is not available, run the command:

```shell
make destroy android
```