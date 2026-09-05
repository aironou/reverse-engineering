---
name: start-android-emulator
description: |
    start ADB shell using android emulator (GUI or headless). use when need to
    use ADB shell or when user asks to start android emulator or ADB shell.
---

# start android emulator

## input

to start android emulator, user should define if emulator should be **headless**
or use **GUI**.

## flow

### start emulator

to start **headless android emulator**, using `terminal`, run the command:

```shell
make android:emulator headless
```

to start **GUI android emulator**, using `terminal`, run the command:

```shell
make android:emulator
```

## verification

after processing this skill flow, using `.setup/android/compose.yml`:

- confirm that `emulator` is running healthy
- confirm that `server` is running healthy
- confirm that `shell` is running
- confirm that there is a tty session to `shell`