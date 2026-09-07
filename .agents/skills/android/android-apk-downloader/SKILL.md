---
name: android-apk-downloader
description: |
    download android applications from google play through the emulator and
    prepare their APK files for reverse engineering. use when an android package
    is not locally available or the user asks to download an android app.
---

# android APK downloader

## input

to download an APK file, user should define the `{{package_name}}` (android
project ID at play store).

## actions

### check package installation

to check whether the package is installed, using `ADB shell`, run the command:

```shell
pm path {{package_name}}
```

the package is installed only when this command succeeds and returns at least
one package path. this command is the source of truth; UI elements are
supporting evidence only.

### search actions at screen

when searching for elements, only consider nodes whose `package` is
`com.android.vending`. identify elements by their semantic role:

- `install_action`: enabled and clickable node, preferably a button, whose 
  `text` or `content-desc` is `Install`
- `update_action`: enabled and clickable node, preferably a button, whose 
  `text` or `content-desc` is `Update`
- `open_action`: enabled and clickable node, preferably a button, whose 
  `text` or `content-desc` is `Open`
- `cancel_action`: enabled and clickable node whose`text` or `content-desc`
  is `Cancel`
- `progress`: node whose class is a progress bar, or whose text describes 
  download or installation progress

### ask user to solve a problem

if a problem requires a manual action from user, then:

1. stop `ADB shell`
2. start a new `ADB shell` in a `GUI android emulator`
3. explain the problem and the relevant contents of the saved UI hierarchy to
   user
4. ask user to solve the problem at GUI
5. wait until user solves the problem

**after user solves the problem** stop `ADB shell` and restart the flow.

### extract package version

using `ADB shell`, run the command:

```shell
dumpsys package {{package_name}} | grep -i versioncode
```

### attach shell to container

using `terminal`, run the command:

```shell
make android:emulator attach
```

## flow

### start ADB shell

start ADB shell in a headless android emulator.

**do not advance in case of error.**

### install android app

#### open app page at play store

before opening the app page, `check package installation`. if it succeeded, set
`preinstalled=true` and skip installation steps. set `preinstalled=false`
otherwise.

using `ADB shell`, run the command:

```shell
am start -a android.intent.action.VIEW -d 'market://details?id={{package_name}}'
```

after opening the page, `search actions at screen` every 2 seconds for at most
30 seconds. if the timeout expires, then `ask user to solve a problem`.

if exactly one `install_action` is available and neither `update_action` nor
`open_action` is available, then click the `install_action` element.

if `update_action`, `open_action`, or multiple `install_action` are available,
then `ask user to solve the problem`.

#### check installation progress

after clicking `install_action` element, check package installation every
10 seconds for at most 5 minutes. in each check, `search actions at screen`. 
`cancel_action` or `progress` can be searched for as supporting evidence.

if the timeout expires, then `ask user to solve a problem`.

**do not advance until `check package installation` succeeds.**

### copy APK files to host

for each file in `check package instalattion` action, as `emulator_path`, using
`terminal`, run the command:

```shell
make android:emulator copy \
  EMULATOR_PATH="{{emulator_path}}" \
  HOST_PATH="{{host_path}}"
```

`host_path` should be `projects/{{package_name}}/artifacts/{{package_version}}
/apk/{{timestamp without timezone}}-{{file name}}.apk`

### uninstall APK

**if `preinstalled=true`, skip uninstall APK steps.**

`attach shell to container` and, using the new shell, run the command:

```shell
rm -rdfv projects/{{package_name}}/artifacts/{{package_version}}/apk
```

using `ADB shell`, run the command:

```shell
pm uninstall {{package_name}}
```

### stop ADB shell

stop android emulator.

## verification

after processing this skill flow:

- confirm that `projects/{{package_name}}/artifacts/{{package_version}}/apk`
  exists;
- confirm that `projects/{{package_name}}/artifacts/{{package_version}}/apk`
  is the only directory created by this skill;
- confirm that every APK file from `check package installation` exists in
  `projects/{{package_name}}/artifacts/{{package_version}}/apk`.