#!/bin/make -f
SHELL = /bin/sh

COMPOSE_ANDROID_FILE_DIR := .setup/android
COMPOSE_ANDROID_FILE := $(COMPOSE_ANDROID_FILE_DIR)/compose.yml
COMPOSE_ANDROID_EMULATOR_FILE := $(COMPOSE_ANDROID_FILE_DIR)/emulator.compose.yml
COMPOSE_ANDROID_EMULATOR_HEADLESS_FILE := $(COMPOSE_ANDROID_FILE_DIR)/emulator-headless.compose.yml

COMPOSE_ANDROID_BIN := docker compose -f $(COMPOSE_ANDROID_FILE)

define android_help
@printf '\n$(TEXT_BOLD)$(TEXT_BLUE)android:$(TEXT_RESET)\n'
@printf '%b%b$(TEXT_RESET)|%b%b$(TEXT_RESET)\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'help android' '' 'print android related help message' \
	'' '' '$(TEXT_CYAN)' 'make help android\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'build android' '' 'build android related containers'\
	'$(TEXT_BRIGHT_BLUE)'  'options:' '' ''\
	'$(TEXT_BRIGHT_MAGENTA)'  '    -B, --always-make' '' 'do not use cache to build'\
	'' '' '$(TEXT_CYAN)' 'make build android [-B, --always-make]\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'destroy android' '' 'destroy android related containers' \
	'$(TEXT_BRIGHT_BLUE)'  'options:' '' '' \
	'$(TEXT_BRIGHT_MAGENTA)'  '    -B, --always-make' '' 'also destroy volumes' \
	'' '' '$(TEXT_CYAN)' 'make destroy android [-B, --always-make]\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'android:emulator' '' 'starts android emulator with ADB shell' \
	'$(TEXT_BRIGHT_BLUE)'  'options:' '' '' \
	'$(TEXT_BRIGHT_MAGENTA)'  '    headless' '' 'use headless emulator' \
	'' '' '$(TEXT_CYAN)' 'make android:emulator headless\n' \
	'$(TEXT_BRIGHT_MAGENTA)'  '    attach' '' 'attach to running ADB shell and open bash' \
	'' '' '$(TEXT_CYAN)' 'make android:emulator attach\n' \
	'$(TEXT_BRIGHT_MAGENTA)'  '    copy' '' 'copy file from emulator' \
	'' '' '$(TEXT_CYAN)' 'make android:emulator copy [emulator path] [host path]\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'android:apkanalyzer' '' 'exec apkanalyzer' \
	'$(TEXT_BRIGHT_BLUE)'  'arguments:' '' ''\
	'$(TEXT_BRIGHT_MAGENTA)'  '    command' '' 'apkanalyzer command' \
	'$(TEXT_BRIGHT_MAGENTA)'  '    apk' '' 'path to APK file' \
	'' '' '$(TEXT_CYAN)' 'make android:apkanalyzer [command] [apk]\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'android:aapt2' '' 'exec aapt2' \
	'$(TEXT_BRIGHT_BLUE)'  'arguments:' '' ''\
	'$(TEXT_BRIGHT_MAGENTA)'  '    command' '' 'aapt2 command' \
	'$(TEXT_BRIGHT_MAGENTA)'  '    apk' '' 'path to APK file' \
	'' '' '$(TEXT_CYAN)' 'make android:aapt2 [command] [apk]\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'android:apksigner' '' 'exec apksigner' \
	'$(TEXT_BRIGHT_BLUE)'  'arguments:' '' ''\
	'$(TEXT_BRIGHT_MAGENTA)'  '    command' '' 'apksigner command' \
	'$(TEXT_BRIGHT_MAGENTA)'  '    apk' '' 'path to APK file' \
	'' '' '$(TEXT_CYAN)' 'make android:apksigner [command] [apk]\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'android:apktool' '' 'exec apktool' \
	'$(TEXT_BRIGHT_BLUE)'  'options:' '' ''\
	'$(TEXT_BRIGHT_MAGENTA)'  '' '' 'exec apktool command' \
	'' '' '$(TEXT_CYAN)' 'make android:apktool [command] [apk]\n' \
	'$(TEXT_BRIGHT_MAGENTA)'  '    copy' '' 'copy file from apktool' \
	'' '' '$(TEXT_CYAN)' 'make android:apktool copy [path]\n' \
| column -s '|' -t -d -N command,description -L | sed -e 's/^/  /'
@echo $(DIVIDER)
endef

define android_choice
$(if $(filter-out android,$(PARAMS)),,$(1))
endef

.PHONY: help
help::
	$(call android_choice,$(android_help))

.PHONY: build
build::
	$(call android_choice,$(COMPOSE_ANDROID_BIN) --profile "*" build $(if $(HAS_FORCE),--no-cache))

.PHONY: destroy
destroy::
	$(call android_choice,$(COMPOSE_ANDROID_BIN) down $(if $(HAS_FORCE),-v))

.PHONY: android\:emulator
android\:emulator: COMMAND := $(firstword $(PARAMS))
android\:emulator: COMMAND_PARAMS := $(filter-out $(COMMAND),$(PARAMS))
android\:emulator: APK := $(lastword $(COMMAND_PARAMS))
android\:emulator:
	xhost +si:localuser:root || exit $$?
ifeq (,$(firstword $(PARAMS)))
	$(COMPOSE_ANDROID_BIN) -f $(COMPOSE_ANDROID_EMULATOR_FILE) run --rm -it shell || true; \
	$(MAKE) destroy android
else ifeq (headless,$(firstword $(PARAMS)))
	$(COMPOSE_ANDROID_BIN) -f $(COMPOSE_ANDROID_EMULATOR_HEADLESS_FILE) run --rm -it shell || true; \
	$(MAKE) destroy android
else ifeq (attach,$(firstword $(PARAMS)))
	$(COMPOSE_ANDROID_BIN) exec shell bash
else ifeq (copy,$(firstword $(PARAMS)))
	$(COMPOSE_ANDROID_BIN) exec shell /entrypoint.sh pull $(COMMAND_PARAMS)
	$(COMPOSE_ANDROID_BIN) cp shell:$(APK) $(APK)
else
	@$(MAKE) help android
endif
	xhost -si:localuser:root

.PHONY: android\:apkanalyzer
android\:apkanalyzer: APK := $(lastword $(PARAMS))
android\:apkanalyzer: COMMAND := $(filter-out $(APK),$(PARAMS))
android\:apkanalyzer:
	$(COMPOSE_ANDROID_BIN) run --rm \
		-v "$(shell pwd)/$(APK):/$(APK):ro" \
		apkanalyzer $(COMMAND) $(APK)

.PHONY: android\:aapt2
android\:aapt2: APK := $(lastword $(PARAMS))
android\:aapt2: COMMAND := $(filter-out $(APK),$(PARAMS))
android\:aapt2:
	$(COMPOSE_ANDROID_BIN) run --rm \
		-v "$(shell pwd)/$(APK):/$(APK):ro" \
		aapt2 $(COMMAND) $(APK)

.PHONY: android\:apksigner
android\:apksigner: APK := $(lastword $(PARAMS))
android\:apksigner: COMMAND := $(filter-out $(APK),$(PARAMS))
android\:apksigner:
	$(COMPOSE_ANDROID_BIN) run --rm \
		-v "$(shell pwd)/$(APK):/$(APK):ro" \
		apksigner $(COMMAND) $(APK)

.PHONY: android\:apktool
android\:apktool: COMMAND := $(firstword $(PARAMS))
android\:apktool: COMMAND_PARAMS := $(filter-out $(COMMAND),$(PARAMS))
android\:apktool: APK := $(lastword $(PARAMS))
android\:apktool: APKTOOL_COMMAND := $(filter-out $(APK),$(COMMAND_PARAMS))
android\:apktool:
ifeq (,$(firstword $(PARAMS)))
	$(COMPOSE_ANDROID_BIN) run \
		-v "$(shell pwd)/$(APK):/$(APK):ro" \
		apktool $(APKTOOL_COMMAND) $(APK)
else ifeq (copy,$(firstword $(PARAMS)))
	$(COMPOSE_ANDROID_BIN) create --no-recreate apktool
	$(COMPOSE_ANDROID_BIN) cp apktool:$(COMMAND_PARAMS) $(COMMAND_PARAMS)
else
	@$(MAKE) help android
endif
