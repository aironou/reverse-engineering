#!/bin/make -f
SHELL = /bin/sh

COMPOSE_ANDROID_FILE_DIR := .setup/android
COMPOSE_ANDROID_FILE := $(COMPOSE_ANDROID_FILE_DIR)/compose.yml
COMPOSE_ANDROID_EMULATOR_FILE := $(COMPOSE_ANDROID_FILE_DIR)/emulator.compose.yml
COMPOSE_ANDROID_EMULATOR_HEADLESS_FILE := $(COMPOSE_ANDROID_FILE_DIR)/emulator-headless.compose.yml

COMPOSE_ANDROID_BIN := docker compose -f $(COMPOSE_ANDROID_FILE)

define ANDROID_HELP
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
	'' '' '$(TEXT_CYAN)' 'make android:emulator [headless]\n' \
| column -s '|' -t -d -N command,description -W description -L | sed -e 's/^/  /'
@echo $(DIVIDER)
endef

define ANDROID_CHOICE
$(if $(filter-out android,$(PARAMS)),,$(1))
endef

.PHONY: help
help::
	$(call ANDROID_CHOICE,$(ANDROID_HELP))

.PHONY: build
build::
	$(call ANDROID_CHOICE,$(COMPOSE_ANDROID_BIN) build $(if $(HAS_FORCE),--no-cache))

.PHONY: destroy
destroy::
	$(call ANDROID_CHOICE,$(COMPOSE_ANDROID_BIN) down $(if $(HAS_FORCE),-v))

.PHONY: android\:emulator
android\:emulator:
	xhost +si:localuser:root || exit $$?
ifeq (,$(PARAMS))
	$(COMPOSE_ANDROID_BIN) -f $(COMPOSE_ANDROID_EMULATOR_FILE) run --rm -it shell || true; \
	$(MAKE) destroy android
else ifeq (headless,$(PARAMS))
	$(COMPOSE_ANDROID_BIN) -f $(COMPOSE_ANDROID_EMULATOR_HEADLESS_FILE) run --rm -it shell || true; \
	$(MAKE) destroy android
else ifeq (attach,$(PARAMS))
	$(COMPOSE_ANDROID_BIN) exec shell bash
else
	@$(MAKE) help android
endif
	xhost -si:localuser:root

