---
name: android-apk-downloader
description: |
    download android applications from google play through the emulator and
    prepare their APK files for reverse engineering. use when an android package
    is not locally available or the user asks to download an android app.
---

# android APK downloader

## requirements

- `ADB shell` available

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

### copy file or path from emulator to container

to copy files from emulator to container, using `terminal` while `ADB shell`
is running, run the command:

```shell
docker compose -f .setup/android/compose.yml exec shell /entrypoint.sh \
  pull {{emulator_path}} {{container_path}}
```

where `{{emulator_path}}` is the path of APK file or directory on emulator and
`{{container_path}}` is the path of APK file or directory on container.

`{{emulator_path}}` is the result of `check package installation` and 
`{{container_path}}` should reflect the directory at host, i.e., `projects/
{{package_name}}/artifacts/{{package_version}}/apk`.

**all filenames should be preserved.**

to check if file or path are in the container, `attach shell to container`
and run the command:

```shell
ls -lha {{container_path}}
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

#### create project directory

**this project should only contain the tools for reverse engineering. every
project artifacts and report should be added to the project repository itself.**

if user has not added a `git submodule` at `projects/{{package_name}}`, ask user
for the submodule URL and add the submodule.

**do not advance if `projects/{{package_name}}` does not exists or if it is not
an initialized `git submodule`.**

APK file should be added to `projects/{{package_name}}/artifacts
/{{package_version}}/apk`, where `{{package_version}}` is the result of 
`extract package version`.

#### copy APK file to container

`check package instalattion` to get path where the package is installed on
emulator and `copy file or path from emulator to container`.

**do not advance if a file or path are not in the container.**

#### copy APK file to host

for each APK file in container as `{{apk_file_in_container}}`, using `terminal`,
run the command:

```shell
make {{apk_file_in_container}}
```

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