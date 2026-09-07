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
	'$(TEXT_BRIGHT_MAGENTA)'  '  -B, --always-make' '' 'do not use cache to build'\
	'' '' '$(TEXT_CYAN)' 'make build android [-B, --always-make]\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'destroy android' '' 'destroy android related containers' \
	'$(TEXT_BRIGHT_BLUE)'  'options:' '' '' \
	'$(TEXT_BRIGHT_MAGENTA)'  '  -B, --always-make' '' 'also destroy volumes' \
	'' '' '$(TEXT_CYAN)' 'make destroy android [-B, --always-make]\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'android:emulator' '' 'start GUI Android emulator with ADB shell' \
	'' '' '$(TEXT_CYAN)' 'make android:emulator\n' \
	'$(TEXT_BRIGHT_BLUE)'  'options:' '' '' \
	'$(TEXT_BRIGHT_MAGENTA)'  '  headless' '' 'use headless emulator' \
	'' '' '$(TEXT_CYAN)' 'make android:emulator headless\n' \
	'$(TEXT_BRIGHT_MAGENTA)'  '  attach' '' 'open Bash in the running emulator shell container' \
	'' '' '$(TEXT_CYAN)' 'make android:emulator attach\n' \
	'$(TEXT_BRIGHT_MAGENTA)'  '  copy' '' 'copy file from emulator' \
	'$(TEXT_BRIGHT_BLUE)'  '  arguments:' '' '' \
	'$(TEXT_BRIGHT_MAGENTA)'  '    EMULATOR_PATH' '' 'path to file in emulator' \
	'$(TEXT_BRIGHT_MAGENTA)'  '    HOST_PATH' '' 'destination path on host' \
	'' '' '$(TEXT_CYAN)' 'make android:emulator copy EMULATOR_PATH="[emulator path]" HOST_PATH="[host path]"\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'android:apkanalyzer' '' 'exec apkanalyzer' \
	'$(TEXT_BRIGHT_BLUE)'  'arguments:' '' ''\
	'$(TEXT_BRIGHT_MAGENTA)'  '  command' '' 'apkanalyzer command and options' \
	'$(TEXT_BRIGHT_MAGENTA)'  '  apk' '' 'path to APK file' \
	'' '' '$(TEXT_CYAN)' 'make -- android:apkanalyzer [command] [apk]\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'android:aapt2' '' 'exec aapt2' \
	'$(TEXT_BRIGHT_BLUE)'  'arguments:' '' ''\
	'$(TEXT_BRIGHT_MAGENTA)'  '  command' '' 'aapt2 command and options' \
	'$(TEXT_BRIGHT_MAGENTA)'  '  apk' '' 'path to APK file' \
	'' '' '$(TEXT_CYAN)' 'make -- android:aapt2 [command] [apk]\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'android:apksigner' '' 'exec apksigner' \
	'$(TEXT_BRIGHT_BLUE)'  'arguments:' '' ''\
	'$(TEXT_BRIGHT_MAGENTA)'  '  command' '' 'apksigner command and options' \
	'$(TEXT_BRIGHT_MAGENTA)'  '  apk' '' 'path to APK file' \
	'' '' '$(TEXT_CYAN)' 'make -- android:apksigner [command] [apk]\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'android:apktool' '' 'exec apktool' \
	'$(TEXT_BRIGHT_BLUE)'  'arguments:' '' ''\
	'$(TEXT_BRIGHT_MAGENTA)'  '  command' '' 'apktool command and options' \
	'$(TEXT_BRIGHT_MAGENTA)'  '  apk' '' 'path to APK file' \
	'' '' '$(TEXT_CYAN)' 'make -- android:apktool [command] [apk]\n' \
	'$(TEXT_BRIGHT_BLUE)'  'options:' '' ''\
	'$(TEXT_BRIGHT_MAGENTA)'  '  copy' '' 'copy file from apktool container to the same path on host' \
	'$(TEXT_BRIGHT_BLUE)'  '  arguments:' '' '' \
	'$(TEXT_BRIGHT_MAGENTA)'  '    HOST_PATH' '' 'path to file in apktool and destination path on host' \
	'' '' '$(TEXT_CYAN)' 'make android:apktool copy HOST_PATH="[host path]"\n' \
| column -s '|' -t -d -N command,description -L | sed -e 's/^/  /'
@echo $(DIVIDER)
endef

define android_choice
$(if $(filter-out android,$(PARAMS)),,$(1))
endef

define android_command_volume_choice
$(if $(2),$(COMPOSE_ANDROID_BIN) run --rm -v "$(shell pwd)/$(3):/$(3):ro" $(1) $(2) $(3),$(COMPOSE_ANDROID_BIN) run --rm $(1) $(2))
endef

.PHONY: help
help::
	$(call android_choice,$(android_help))

.PHONY: build
build::
	$(call android_choice,$(COMPOSE_ANDROID_BIN) --profile "*" build $(if $(HAS_FORCE),--no-cache))

.PHONY: destroy
destroy::
	$(call android_choice,$(COMPOSE_ANDROID_BIN) down --remove-orphans $(if $(HAS_FORCE),-v))

.PHONY: android\:emulator
android\:emulator:
	xhost +si:localuser:root || exit $$?
	$(COMPOSE_ANDROID_BIN) create --no-recreate shell
ifeq (,$(firstword $(PARAMS)))
	$(COMPOSE_ANDROID_BIN) -f $(COMPOSE_ANDROID_EMULATOR_FILE) run --rm -it shell || true; \
	$(MAKE) destroy android
else ifeq (headless,$(firstword $(PARAMS)))
	$(COMPOSE_ANDROID_BIN) -f $(COMPOSE_ANDROID_EMULATOR_HEADLESS_FILE) run --rm -it shell || true; \
	$(MAKE) destroy android
else ifeq (attach,$(firstword $(PARAMS)))
	$(COMPOSE_ANDROID_BIN) exec shell bash
else ifeq (copy,$(firstword $(PARAMS)))
	mkdir -p $(shell dirname $(HOST_PATH))
	$(COMPOSE_ANDROID_BIN) exec shell mkdir -p $(shell dirname $(HOST_PATH))
	$(COMPOSE_ANDROID_BIN) exec shell /entrypoint.sh pull $(EMULATOR_PATH) $(HOST_PATH)
	$(COMPOSE_ANDROID_BIN) cp "shell:$(HOST_PATH)" "$(HOST_PATH)"
else
	@$(MAKE) help android
endif
	xhost -si:localuser:root

.PHONY: android\:apkanalyzer
android\:apkanalyzer: APK := $(lastword $(PARAMS))
android\:apkanalyzer: COMMAND := $(filter-out $(APK),$(PARAMS))
android\:apkanalyzer:
	$(call android_command_volume_choice,apkanalyzer,$(COMMAND),$(APK))

.PHONY: android\:aapt2
android\:aapt2: APK := $(lastword $(PARAMS))
android\:aapt2: COMMAND := $(filter-out $(APK),$(PARAMS))
android\:aapt2:
	$(call android_command_volume_choice,aapt2,$(COMMAND),$(APK))

.PHONY: android\:apksigner
android\:apksigner: APK := $(lastword $(PARAMS))
android\:apksigner: COMMAND := $(filter-out $(APK),$(PARAMS))
android\:apksigner:
	$(call android_command_volume_choice,apksigner,$(COMMAND),$(APK))

.PHONY: android\:apktool
android\:apktool: APK := $(lastword $(PARAMS))
android\:apktool: COMMAND := $(filter-out $(APK),$(PARAMS))
android\:apktool:
ifeq (copy,$(firstword $(PARAMS)))
	mkdir -p $(shell dirname $(HOST_PATH))
	$(COMPOSE_ANDROID_BIN) create --no-recreate apktool
	$(COMPOSE_ANDROID_BIN) cp "apktool:$(HOST_PATH)" "$(HOST_PATH)"
else
	$(call android_command_volume_choice,apktool,$(COMMAND),$(APK))
endif
