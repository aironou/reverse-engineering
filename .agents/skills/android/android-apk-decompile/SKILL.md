---
name: android-apk-decompile
description: decompile APK file. use when need to decompile APK.
---

# android APK decompile

## input

to decompile an APK file, user should define the path to the APK file, also
known as `apk_file`.

## flow

### check if decompilation is necessary

an APK file should be decompiled only if it contains `dex files`.

to check if APK contains, using `terminal`, run the command:

```shell
unzip -Z1 {{apk_file}} | grep -E '^classes[\d]*\.dex$'
```

**if there isn't `dex files`, it is not necessary to run this skill.**

### decompile APK file

set `output` with the value `projects/{{package_name}}/artifacts
/{{package_version}}/apk/decompiled/{{APK file name}}`.

**missing information to set `output` should be obtained inspecting APK file.**

using `terminal`, run the command:

```shell
make -- android:jadx --output-dir "{{output}}" "{{apk_file}}"
```

### copy decompiled APK to host

using `terminal`, run the command:

```shell
make android:jadx copy \
  HOST_PATH="{{output}}"
```

## verification

after decompiling APK file:

- confirm that `output` exists;
- confirm that `output` contains