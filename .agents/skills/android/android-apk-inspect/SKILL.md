---
name: android-apk-inspect
description: |
    inspect APK file. use when need to get APK technical information like
    package name, package version, version name, min SDK, target SDK,
    compiled SDK version, certificate data, permissions, activities, services,
    receivers, providers, application class, debuggable flag, allow backup flag,
    native libraries, uses features and network security config.
---

# android APK inspect

## input

to inspect an APK file, user should define the path to the APK file, also known
as `{{apk_file}}`.

## actions

### get android manifest

if `android_manifest` is not defined, using `terminal`, run the command:

```shell
make android:apkanalyzer manifest print {{apk_file}}
```

using the dumped XML, set `android_manifest` and keep it save until the end of
session because this will be used to get values during inspection.

### get intent filters

for each `intent-filter` node in the node defined by the user, set a new
`intent_filter` with properties below:

| property      | node       | attribute            | note                    |
|---------------|------------|----------------------|-------------------------|
| `priority`    |            | `android:priority`   |                         |
| `order`       |            | `android:order`      |                         |
| `auto_verify` |            | `android:autoVerify` |                         |
| `label`       |            | `android:label`      |                         |
| `action`      | `action`   | `android:name`       | set as a list of string | 
| `categories`  | `category` | `android:name`       | set as a list of string |

for each `data` node in `intent-filter` node, set a new `data` with properties
as below:

| property                       | attribute             |
|--------------------------------|-----------------------|
| `scheme`                       | `android:scheme`      |
| `host`                         | `android:host`        |
| `port`                         | `android:port`        |
| `path`                         | `android:path`        |
| `path_prefix`                  | `android:pathPrefix`  |
| `path_pattern`                 | `android:pathPattern` |
| `mime_type`                    | `android:mimeType`    |
| `scheme_specific_part`         | `android:ssp`         |
| `scheme_specific_part_prefix`  | `android:sspPrefix`   |
| `scheme_specific_part_pattern` | `android:sspPattern`  |

set `intent_filter.data` with the `data` list.

### get metadata

for each `meta-data` node in the node defined by the user, set a new `metadata`
with properties as below:

| property   | value              |
|------------|--------------------|
| `name`     | `android:name`     |
| `resource` | `android:resource` |

### get certificates

for each `certificates` node in the `trust-anchors` node in the node defined by
the user, set a new `certificate` with properties as below:

| property        | attribute      |
|-----------------|----------------|
| `source`        | `src`          |
| `override_pins` | `overridePins` |

### get domain config

for each `domain-config` node in the node defined by the user, set a new
`domain_config` with properties as below:

| property                      | attribute                   |
|-------------------------------|-----------------------------|
| `cleartext_traffic_permitted` | `cleartextTrafficPermitted` |

for each `domain` node in `domain-config` node, set a new `domain` with
properties as below:

| property             | attribute           |
|----------------------|---------------------|
| `include_subdomains` | `includeSubdomains` |
| `domain`             |                     |

set `domain_config.domains` with the `domain-config` list.

for `pin-set` node in `domain-config` node, set a new `pin_set` with properties
as below:

| property     | attribute    |
|--------------|--------------|
| `expiration` | `expiration` |

for each `pin` node in `pin-set` node, set a new `pin` with properties as below:

| property | attribute |
|----------|-----------|
| `digest` | `digest`  |
| `value`  |           |

set `pin_set.pins` with the `pin` list.

set `domain_config.pin_set` with `pin_set`.

set `domain_config.certificates` with the `certificates` of `domain-config`
node.

set `domain_config.domains_config` with the `domain config` list in current
`domain-config` node.

for each `domain-config` node in current `domain-config` node

## flow

### inspect package

#### name

using `terminal`, run the command:

```shell 
make android:apkanalyzer manifest application-id {{apk_file}}
```

set `name` with the command result.

#### version

using `terminal`, run the command:

```shell 
make android:apkanalyzer manifest version-code {{apk_file}}
```

set `version` with the command result.

#### version name 

using `terminal`, run the command:

```shell 
make android:apkanalyzer manifest version-name {{apk_file}}
```

set `version_name` with the command result.

#### min SDK

using `terminal`, run the command:

```shell
make android:apkanalyzer manifest min-sdk {{apk_file}}
```

set `min_sdk` with the command result.

#### target SDK

using `terminal`, run the command:

```shell
make android:apkanalyzer manifest target-sdk {{apk_file}}
```

set `target_sdk` with the command result.

#### compiled SDK version

using `terminal`, run the command:

```shell
make android:aapt2 dump badging {{apk_file}}
```

set `compile_sdk` with the value of compile SDK version.

#### certificate data

using `terminal`, run the command:

```shell
make android:apksigner "verify --verbose --print-certs" {{apk_file}}
```

using the command result, set `certificate_data` with properties as below:

| property                          | value                                  |
|-----------------------------------|----------------------------------------|
| `verified_v1_scheme`              | verified using v1 scheme               |
| `verified_v2_scheme`              | verified using v2 scheme               |
| `verified_v3_scheme`              | verified using v3 scheme               |
| `verified_v3_1_scheme`            | verified using v3.1 scheme             |
| `verified_v4_scheme`              | verified using v4 scheme               |
| `verified_source_stamp`           | verified for source stamp              |
| `source_stamp_dn`                 | source stamp signer DN                 |
| `source_stamp_sha_256`            | source stamp signer SHA-256            | 
| `source_stamp_sha_1`              | source stamp signer SHA-1              | 
| `source_stamp_md5`                | source stamp signer MD5                | 
| `source_stamp_key_algo`           | source stamp signer key algorithm      | 
| `source_stamp_key_size`           | source stamp signer key size           | 
| `source_stamp_public_key_sha_256` | source stamp signer public key SHA-256 | 
| `source_stamp_public_key_sha_1`   | source stamp signer public key SHA-1   | 
| `source_stamp_public_key_md5`     | source stamp signer public key MD5     | 
| `source_stamp_timestamp`          | source stamp timestamp                 | 

for each signer in the command result, set a new `signer` with properties as
below:

| property              | value                      |
|-----------------------|----------------------------|
| `certificate_dn`      | signer certificate DN      |
| `certificate_sha_256` | signer certificate SHA-256 |
| `certificate_sha_1`   | signer certificate SHA-1   |
| `certificate_md5`     | signer certificate MD5     |
| `key_algorithm`       | signer key algorithm       |
| `key_size`            | signer key size            |
| `public_key_sha_256`  | signer public key SHA-256  |
| `public_key_sha_1`    | signer public key SHA-1    |
| `public_key_md5`      | signer public key MD5      |

set `certificate_data.signers` with the `signer` list.

#### permissions

using `terminal`, run the command:

```shell
make android:apkanalyzer manifest permissions {{apk_file}}
```

set `permissions_requested` with the command result.

for each node `permission` in `android_manifest`, set a new `permission` with
properties as below:

| property           | attribute                 |
|--------------------|---------------------------|
| `name`             | `android:name`            |
| `protection_level` | `android:protectionLevel` |

set `permissions_defined` with the `permission` list.

#### activities

for each `activity` node in `android_manifest`, set `activity` with properties
as below:

| property        | attribute              | note                    |
|-----------------|------------------------|-------------------------|
| `name`          | `android:name`         | use full qualified name |
| `exported`      | `android:exported`     |                         |
| `enabled`       | `android:enabled`      |                         |
| `permission`    | `android:permission`   |                         |
| `process`       | `android:process`      |                         |
| `launch_mode`   | `android:launchMode`   |                         |
| `task_affinity` | `android:taskAffinity` |                         |

set `activity.intent_filters` with the `intent_filter` list in `activity` node.

set `activities` with the `activity` list.

for each `activity-alias` node in `android_manifest`, set a new `activity-alias`
with properties as below:

| property           | attribute                | note                    |
|--------------------|--------------------------|-------------------------|
| `name`             | `android:name`           | use full qualified name |
| `target_activity`  | `android:targetActivity` | use full qualified name |

set `activity_alias.intent_filters` with the `intent_filter` list in
`activity-alias` node.

set `activity_aliases` with the `activity_alias` list.

#### services

for each `service` node in `android_manifest`, set `service` with properties as
below:

| property                   | attribute                       | note                    |
|----------------------------|---------------------------------|-------------------------|
| `name`                     | `android:name`                  | use full qualified name |
| `exported`                 | `android:exported`              |                         |
| `permission`               | `android:permission`            |                         |
| `process`                  | `android:process`               |                         |
| `foreground_service_types` | `android:foregroundServiceType` | set as a list of string |
| `isolated_process`         | `android:isolatedProcess`       |                         |
| `stop_with_task`           | `android:stopWithTask`          |                         |
| `direct_boot_aware`        | `android:directBootAware`       |                         |

set `service.intent_filters` with the `intent_filter` list in `service` node.

set `service.metadata` with the `metadata` list in `service` node.

set `services` with the `service` list.

#### receivers

for each `receiver` node in `android_manifest`, set `receiver` with properties
as below:

| property            | attribute                 | note                    |
|---------------------|---------------------------|-------------------------|
| `name`              | `android:name`            | use full qualified name |
| `exported`          | `android:exported`        |                         |
| `enabled`           | `android:enabled`         |                         |
| `permission`        | `android:permission`      |                         |
| `process`           | `android:process`         |                         |
| `direct_boot_aware` | `android:directBootAware` |                         |
| `priority`          | `android:priority`        |                         |

set `receiver.intent_filters` with the `intent_filter` list in `receiver` node.

set `receiver.metadata` with the `metadata` list in `receiver` node.

set `receivers` with the `receiver` list.

#### providers

for each `provider` node in `android_manifest`, set `provider` with properties
as below:

| property               | attribute                     | note                    |
|------------------------|-------------------------------|-------------------------|
| `name`                 | `android:name`                | use full qualified name |
| `authorities`          | `android:authorities`         |                         |
| `exported`             | `android:exported`            |                         |
| `enabled`              | `android:enabled`             |                         |
| `permission`           | `android:permission`          |                         |
| `read_permission`      | `android:readPermission`      |                         |
| `write_permission`     | `android:writePermission`     |                         |
| `grant_uri_permission` | `android:grantUriPermissions` |                         |
| `process`              | `android:process`             |                         |
| `multiprocess`         | `android:multiprocess`        |                         |
| `syncable`             | `android:syncable`            |                         |
| `direct_boot_aware`    | `android:directBootAware`     |                         |
| `init_order`           | `android:initOrder`           |                         |

for each `path-permission` in `provider` node, set a new `path_permission` with
properties as below:

| property           | attribute                 |
|--------------------|---------------------------|
| `path_prefix`      | `android:pathPrefix`      |
| `path_pattern`     | `android:pathPattern`     |
| `read_permission`  | `android:readPermission`  |
| `write_permission` | `android:writePermission` |

set `provider.path_permissions` with the `path_permission` list.

for each `grant-ui-permission` node in `provider` node set a new
`grant_ui_permission` with properties as below:

| name          | attribute            |
|---------------|----------------------|
| `path_prefix` | `android:pathPrefix` |

set `provider.grant_ui_permissions` with the `grant_ui_permission` list.

set `provider.metadata` with the `metadata` list in `provider` node.

set `providers` with the `provider` list.

#### application

for `application` node in `android_manifest`, set `application` with properties
as below:

| property                  | attribute                       | note                    |
|---------------------------|---------------------------------|-------------------------|
| `name`                    | `android:name`                  | use full qualified name |
| `debuggable`              | `android:debuggable`            |                         |
| `allow_backup`            | `android:allowBackup`           |                         |
| `full_backup_content`     | `android:fullBackupContent`     |                         |
| `data_extraction_rules`   | `android:dataExtractionRules`   |                         |
| `network_security_config` | `android:networkSecurityConfig` |                         |

#### native libraries

using `terminal`, run the command:

```shell
unzip -Z1 {{apk_file}} | grep -E '^lib/[^/]+/[^/]+\.so$'
```

for each line, consider the value as: `lib/{abi}/{name}`.

for each line in command result, set a new `native_library` with properties as
below:

| property | value        |
|----------|--------------|
| `name`   | `{name}`     |
| `abi`    | `{abi}`      |
| `path`   | line content |
| `source` | `{apk_file}` |

set `native_libraries` with the `native_library` list.

#### uses features

for each node `uses-feature` in `android_manifest`, set a new `uses_feature`
with properties as below:

| property     | attribute             |
|--------------|-----------------------|
| `name`       | `android:name`        |
| `required`   | `android:required`    |
| `open_gl_es` | `android:glEsVersion` |

set `uses_features` with the `uses_feature` list.

#### network security config

using `terminal`, run the command:

```shell
make android:apkanalyzer resource xml --file res/{{nsc}}.xml {{apk_file}}
```

where `{{nsc}}` is the value of `application.network_security_config`. set
`nsc` with the node `network-security-config` in command value.

for `base-config` node in `nsc`, set `base_config` with properties as below:

| property               | attribute                   |
|------------------------|-----------------------------|
| `clear_text_permitted` | `clearTextTrafficPermitted` |

set `base_config.certificates` with the `certificates` of `base-config` node.

set `network_security_config.base_config` with the `base_config` value.

set `network_security_config.domains_config` with the `domain config` list in
`nsc`.

set `network_security_config.debug_override.certificates` with the
`certificates` in `debug-overrides` node in `nsc`.

### generate inspect file

#### create project directory

inspect file should be added to `projects/{{name}}/artifacts/{{version}}
/analysis/inspect`.

#### generate JSON file

create a new JSON file in project directory, using
`{{file name}}-{{timestamp without timezone}}.json` as name, with the values as below:

```json
{
    "name": "{{name}}",
    "version": {
        "version": "{{version}}",
        "name": "{{version_name}}"
    },
    "sdk": {
        "min": "{{min_sdk}}",
        "target": "{{target_sdk}}",
        "compiled": "{{compiled_sdk_version}}"
    },
    "certificate": "{{certificate_data}}",
    "permissions": {
        "requested": "{{permissions_requested}}",
        "defined": "{{permissions_defined}}"
    },
    "activities": "{{activities}}",
    "activities_aliases": "{{activities_aliases}}",
    "services": "{{services}}",
    "receivers": "{{receivers}}",
    "providers": "{{providers}}",
    "application": "{{application}}",
    "native_libraries": "{{native_libraries}}",
    "uses_features": "{{uses_features}}",
    "network_security_config": "{{network_security_config}}"
}
```

**this file should not contain another data that was not requested.**