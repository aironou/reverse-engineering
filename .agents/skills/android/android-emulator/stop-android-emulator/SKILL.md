---
name: stop-android-emulator
description: |
    stop android emulator (GUI or headless). use when need to stop ADB shell or
    android emulator, or when user asks to stop android emulator or ADB shell.
---

# stop android emulator

## flow

### stop ADB shell

using `ADB shell` itself, run the command:

```shell
exit
```

if `ADB shell` is not available, run the command:

```shell
make destroy android
```

## verification

after processing this skill flow, using `.setup/android/compose.yml`:

- confirm that `emulator` is stopped
- confirm that `server` is stopped
- confirm that `shell` is stopped