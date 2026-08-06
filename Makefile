#!/bin/make -f
SHELL = /bin/sh
MAKEFLAGS += --no-print-directory

PARAMS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
HAS_FORCE := $(findstring B,$(firstword $(MAKEFLAGS)))

ifneq ($(MAKE_TERMOUT),)
	TEXT_RESET := \033[0m
	TEXT_BOLD := \033[1m
	TEXT_BLUE := \033[34m
	TEXT_MAGENTA := \033[35m
	TEXT_CYAN := \033[36m
	TEXT_BRIGHT_BLUE := \033[94m
	TEXT_BRIGHT_MAGENTA := \033[95m
	DIVIDER := $(shell printf '%*s\n' $(shell tput cols) ' ' | tr ' ' '-')
else
	TEXT_RESET :=
	TEXT_BOLD :=
	TEXT_BLUE :=
	TEXT_MAGENTA :=
	TEXT_CYAN :=
	TEXT_BRIGHT_BLUE :=
	TEXT_BRIGHT_MAGENTA :=
	DIVIDER :=
endif

ifneq ($(strip $(PARAMS)),)
.PHONY: $(PARAMS)
$(PARAMS)::
	@:
endif

define HELP
@printf '\n$(TEXT_BOLD)$(TEXT_BLUE)general:$(TEXT_RESET)\n'
@printf '%b%b$(TEXT_RESET)|%b%b$(TEXT_RESET)\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'help' '' 'print this help message' \
	'' '' '$(TEXT_CYAN)' 'make help\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'build' '' 'build environments' \
	'$(TEXT_BRIGHT_BLUE)'  'options:' '' ''\
	'$(TEXT_BRIGHT_MAGENTA)'  '    -B, --always-make' '' 'do not use cache to build'\
	'' '' '$(TEXT_CYAN)' 'make build [-B, --always-make]\n' \
	'$(TEXT_BOLD)$(TEXT_MAGENTA)' 'destroy' '' 'destroy environments' \
	'$(TEXT_BRIGHT_BLUE)'  'options:' '' ''\
	'$(TEXT_BRIGHT_MAGENTA)'  '    -B, --always-make' '' 'also destroy volumes'\
	'' '' '$(TEXT_CYAN)' 'make build [-B, --always-make]\n' \
| column -s '|' -t -d -N command,description -W description -L | sed -e 's/^/  /'
@echo $(DIVIDER)
endef

.PHONY: help
help::
ifeq (,$(PARAMS))
	$(call HELP)
endif

.PHONY: build
build::

.PHONY: detroy
destroy::

include .setup/makefile/*.mk

.env:
ifneq (,$(HAS_FORCE))
	cp -vu .env.example .env
else
	cp -vn .env.example .env
endif