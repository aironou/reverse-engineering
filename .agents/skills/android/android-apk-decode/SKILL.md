---
name: android-apk-decode
description: decode APK file. use when need to decode an APK.
---

# android APK decode

## input

to decode an APK file, user should define the path to the APK file, also known
as `apk_file`.

## flow

### decode APK file

set `output` with the value `projects/{{package_name}}/artifacts
/{{package_version}}/apk/decoded/{{APK file name}}`.

**missing information to set `output` should be obtained inspecting APK file.**

using `terminal`, run the command:

```shell
make -- android:apktool decode {{apk_file}} --output {{output}} {{apk_file}}
```

### copy decoded APK to host

using `terminal`, run the command:

```shell
make android:apktool copy \
  HOST_PATH="{{output}}"
```

## verification

after decoding APK file:

- confirm that `output` exists;
- confirm that `output` contains `AndroidManifest.xml`;
- confirm that `output` contains `apktool.yml`;