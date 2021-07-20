# --- init_env and the makefile.env generation and BUILD_VARS-----

# The defult build dir, if we have only one it'll be easier to cleanup
export BUILD_DIR ?= build
BUILD_VARS += BUILD_DIR

#shell doesn't get the exported vars so we need to spin the ones we want, which should be in BUILD_VARS
SHELL_EXPORTS := $(foreach v,$(BUILD_VARS), $(v)='$($(v))')
# if no build.sh var is not set then call the the init_env script directly
# if its set then call build.sh and assume its setting up variables and will call the main init_env where needed
ifdef build.sh
shResults := $(shell $(SHELL_EXPORTS) $(build.sh) make_env_file $(BUILD_ENV) $(DB_VENDOR))
else
shResults := $(shell $(SHELL_EXPORTS) $(SHIPKIT_BIN)/init_env init_and_create_env_file $(BUILD_ENV) $(DB_VENDOR))
endif
ifneq ($(.SHELLSTATUS),0)
  $(error error with init_env or build.sh $(shResults))
endif

makefile_env := ./$(BUILD_DIR)/make/makefile.env
# import/sinclude the variables file to make it availiable to make as well
sinclude $(makefile_env)
# now re-export them so for future shell calls, BUILD_VARS is the list of them all
export $(BUILD_VARS)
# export the list too
export BUILD_VARS

# --- END init_env and the makefile.env generation -----

# as shipkit installs stuff on demand this is where it should go, should be absolute so when calling in dif dir it works
export SHIPKIT_INSTALLS ?= $(abspath $(BUILD_DIR)/installs)


HELP_AWK := $(SHIPKIT_MAKEFILES)/help.awk

# see Target-specific Variable Values for above https://www.gnu.org/software/make/manual/html_node/Target_002dspecific.html
# done so main Makefile is seperate and comes last in awk so any help comments win for main file
help: _HELP_F := $(firstword $(MAKEFILE_LIST))

## default, lists help for targets
help: | _program_awk
	@awk -f $(HELP_AWK) $(wordlist 2,$(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)) $(_HELP_F)

.PHONY: help

## list all the availible Make targets, including the targets hidden from core help
help-all:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort -u | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: help-all

# Old way before phony for forcing targets to run.
# useful when .PHONY doesn't help, plus it looks a bit cleaner in many cases than .phony
FORCE:
.PHONY: FORCE

## list the BUILD_VARS in the build/make env
log-vars: FORCE
	$(foreach v, $(sort $(BUILD_VARS)), $(info $(v) = $($(v))))

# logs all the make variables, get ready for some noise
log-make-vars: FORCE
	$(foreach v, $(.VARIABLES), $(info $(v) = $($(v))))

# for debugging, calls the build.sh log-vars to sanity check
log-buildsh-vars: FORCE
	$(build.sh) log-vars

# list all the functions sourced into the build.sh
list-functions: FORCE
	$(build.sh) list-functions

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

# ---- Logging ----
# usage example : $(call log, logging message $(SomeVar));

# Provides two callables, `log` and `_log`, to facilitate consistent
# user-defined output, formatted using tput when available.
#
# Override TPUT_PREFIX to alter the formatting.
TPUT        := $(shell which tput 2> /dev/null)
TPUT_PREFIX := $(TPUT) bold;
TPUT_SUFFIX := $(TPUT) sgr0
TPUT_RED    := $(TPUT) setaf 1;
TPUT_GREEN  := $(TPUT) setaf 2;
TPUT_YELLOW := $(TPUT) setaf 3;
LOG_PREFIX  ?= ===>

# if not TPUT then blank out the vars
ifeq (,$(and $(TPUT),$(TERM)))
TPUT_PREFIX :=
TPUT_SUFFIX :=
TPUT_RED    :=
TPUT_GREEN  :=
TPUT_YELLOW :=
endif # end tput check

define _log
	@$(TPUT_PREFIX) echo "$(if $(LOG_PREFIX),$(LOG_PREFIX) )$(1)"; $(TPUT_SUFFIX)
endef

define _warn
	@$(TPUT_PREFIX) $(TPUT_YELLOW) echo "$(if $(LOG_PREFIX),$(LOG_PREFIX) )$(1)"; $(TPUT_SUFFIX)
endef

define _error
	@$(TPUT_PREFIX) $(TPUT_RED) echo "$(if $(LOG_PREFIX),$(LOG_PREFIX) )$(1)"; $(TPUT_SUFFIX)
endef

define log
	@$(_log)
endef

# Provides callables `download` and `download_to`.
# * `download`: fetches a url `$(1)` piping it to a command specified in `$(2)`.
#   Usage: `$(call download,$(URL),tar -xf - -C /tmp/dest)`
#
# * `download_to`: fetches a url `$(1)` and writes it to a local path specified in `$(2)`.
#   Usage: `$(call download_to,$(URL),/tmp/dest)`
#
# Requires: curl
#
# Additional command line parameters may be passed to curl via CURL_OPTS.
# For example, `CURL_OPTS += -s`.
#
CURL_OPTS ?= --location --silent
DOWNLOADER = curl $(CURL_OPTS)
DOWNLOAD_FLAGS :=
DOWNLOAD_TO_FLAGS := --write-out "%{http_code}" -o

define download
	$(DOWNLOADER) $(DOWNLOAD_FLAGS) "$(1)" | $(2)
endef

define download_to
	$(DOWNLOADER) $(DOWNLOAD_TO_FLAGS) $(2) "$(1)"
endef

# Provides variables useful for determining the operating system we're running
# on.
#
# OS_NAME will reflect the name of the operating system: Darwin, Linux or Windows
# OS_CPU will be either x86 (32bit) or amd64 (64bit)
# OS_ARCH will be either i686 (32bit) or x86_64 (64bit)
#
OS ?=
ifeq (Windows_NT,$(OS))
OS_NAME := Windows
OS_CPU  := $(call _lower,$(PROCESSOR_ARCHITECTURE))
OS_ARCH := $(if $(findstring amd64,$(OS_CPU)),x86_64,i686)
else
OS_NAME := $(shell uname -s)
OS_ARCH := $(shell uname -m)
OS_CPU  := $(if $(findstring 64,$(OS_ARCH)),amd64,x86)
endif

test-logging-os: FORCE
	$(call log, log OS_NAME $(OS_NAME))
	$(call _log, _log OS_ARCH $(OS_ARCH))
	$(call _warn, _warn OS_CPU $(OS_CPU))
	$(call _error, sample _error $(OS_CPU))