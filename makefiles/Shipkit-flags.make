# The default options and configs for makefile
# make it a bash shell for recipes
SHELL := $(SHIPKIT_BIN)/make_shell
# SHELL := /bin/bash

.DEFAULT_GOAL := help

# no need for @ with this on, will keep it silent, pass something to VERBOSE to show it all
$(VERBOSE).SILENT:

# the whole target recipe is run, instead of one shell per line
.ONESHELL:

# best practice settings for bash scripts, http://redsymbol.net/articles/unofficial-bash-strict-mode/
# .SHELLFLAGS := -eu -o pipefail -c

# if a Make rule fails, it’s target file is deleted. This ensures the next time you run Make,
# it’ll properly re-run the failed rule, and guards against broken files.
# .DELETE_ON_ERROR:

MAKEFLAGS += --no-builtin-rules --no-print-directory

# verify its not an arcane mac version of make
ifeq ($(filter undefine,$(value .FEATURES)),)
  $(error The build system does not work properly with GNU Make $(MAKE_VERSION). please use GNU Make 3.82 or above. \
	for mac run `brew install make` and then follow the directions on modifying your path so new `make` works
  )
endif
