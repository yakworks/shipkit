# The "main" utility functions and helpers useful for the common case. Most
# our makefiles require this file, so it's sensible to `include` it first.
# ideas pulled from https://github.com/martinwalsh/ludicrous-makefiles	
# make default shell bash
SHELL := /bin/bash
# -r is Do not use the built-in rules specified in the system makefile. 
# the no-print is for gnu to not show the entering dir noise
MAKEFLAGS += -rR --no-print-directory
# this grabs the path that this shipkit.make is in.
export SHIPKIT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
export SHIPKIT_BIN := $(SHIPKIT_DIR)/bin
SHIPKIT_MAKEFILES := $(SHIPKIT_DIR)/makefiles
include $(SHIPKIT_MAKEFILES)/Shipkit-core.make
# include boilerplate to set BUILD_ENV and DB from targets
include $(SHIPKIT_MAKEFILES)/env-db.make

# The defult build dir, if we have only one it'll be easier to cleanup
export BUILD_DIR ?= build
BUILD_VARS += BUILD_DIR

SHELL_EXPORTS := $(foreach v,$(BUILD_VARS), $(v)='$($(v))')
# calls either th projects build.sh to build the vairables file for make or
# if no build.sh is specified then makes the call directly to init_env
# need to add the exports we want as they dont seem to get passed through with shell function like they do in targets
ifdef build.sh
shResults := $(shell $(SHELL_EXPORTS) $(build.sh) make_env_file $(BUILD_ENV) $(DB_VENDOR))
else 
shResults := $(shell $(SHELL_EXPORTS) $(SHIPKIT_BIN)/init_env init_and_create_env_file $(BUILD_ENV) $(DB_VENDOR))
endif
# uncomment to debug results
# $(info shResults=$(shResults))

makefile_env := ./$(BUILD_DIR)/make/makefile.env
# import/sinclude the variables file to make it availiable to make as well
sinclude $(makefile_env)
# now re-export them so for future shell calls, BUILD_VARS is the list of them all	
export $(BUILD_VARS)
# export the list too
export BUILD_VARS

include $(SHIPKIT_MAKEFILES)/release.make

HELP_AWK := $(SHIPKIT_MAKEFILES)/help.awk

# Useful for forcing targets to build when .PHONY doesn't help, plus it looks a bit cleaner in many cases than .phony
FORCE:
.PHONY: FORCE

# see Target-specific Variable Values for above https://www.gnu.org/software/make/manual/html_node/Target_002dspecific.html
# done so main Makefile is seperate and comes last in awk so any help comments win for main file
help: _HELP_F := $(firstword $(MAKEFILE_LIST))

## default, lists help for targets
help: | _program_awk
	@awk -f $(HELP_AWK) $(wordlist 2,$(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)) $(_HELP_F)

.PHONY: help
.DEFAULT_GOAL := help

## list the BUILD_VARS in the build/make env
log-vars: FORCE
	$(foreach v, $(sort $(BUILD_VARS)), $(info $(v) = $($(v))))

log-make_vars: FORCE
	$(foreach v, $(.VARIABLES), $(info $(v) = $($(v))))

# for debugging, calls the build.sh log-vars to sanity check
log-buildsh-vars: FORCE
	$(build.sh) log-vars

# list all the functions sourced into the build.sh
list-functions: FORCE
	$(build.sh) list-functions

.PHONY: help-all
## list all the availible Make targets, including the targets hidden from core help
help-all:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort -u | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

# Helper target for declaring an external executable as a recipe dependency.
# For example,
#   `my_target: | _program_awk`
# will fail before running the target named `my_target` if the command `awk` is
# not found on the system path.
_program_%: FORCE
	@_=$(or $(shell which $* 2> /dev/null),$(error `$*` command not found. Please install `$*` and try again))

# Helper target for checking required environment variables.
#
# For example,
#   `my_target`: | _verify_FOO`
#
# will fail before running `my_target` if the variable `FOO` is not declared.
_verify_%: FORCE
	@_=$(if $($*),,$(error `$*` is not defined or is empty))

# text manipulation helpers
_awk_case = $(shell echo | awk '{ print $(1)("$(2)") }')
lc = $(call _awk_case,tolower,$(1))
uc = $(call _awk_case,toupper,$(1))

# $(info BUILD_DIR=$(BUILD_DIR))
$(BUILD_DIR):
	mkdir -p $@


