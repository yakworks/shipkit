# --- init_env and the makefile.env generation and BUILD_VARS-----

# path to core scripts
export BASHKIT_CORE ?= $(SHIPKIT_BIN)/core

# The defult build dir, if we have only one it'll be easier to cleanup
export BUILD_DIR ?= build
# make a unique makefile using MAKELEVEL, which is incrmented for each make subprocess.
# so if make calls a make target it doesn't collide, they can be different based on whats passed for DBMS for example
export MAKE_ENV_FILE ?= $(BUILD_DIR)/make/makefile$(MAKELEVEL).env

SHELL_VARS += VERBOSE_LOG BUILD_DIR MAKE_ENV_FILE DBMS
#shell doesn't get the exported vars so we need to spin the ones we want, which should be in BUILD_VARS
SHELL_EXPORTS := $(foreach v,$(SHELL_VARS), $(v)='$($(v))')
# if no build.sh var is not set then use the the init_env script directly
# if its set then call build.sh and assume it sourced in /init_env and will
# be setting up variables and/or potentially overriding make_env
build.sh ?= $(SHIPKIT_BIN)/init_env
# we do this in subshell so it forces the file to be generated before the sindlues happens
shResults := $(shell $(SHELL_EXPORTS) $(build.sh) make_env $(BUILD_ENV))
ifneq ($(.SHELLSTATUS),0)
  $(error error with init_env or build.sh $(shResults))
endif
ifeq (true,$(VERBOSE))
  $(info make_env results: $(shResults))
endif

# import/sinclude the variables file to make it availiable to make as well
sinclude $(MAKE_ENV_FILE)
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
print-make-vars: FORCE
	$(foreach v, $(.VARIABLES), $(info $(v) = $($(v))))

# Helper target for declaring an external executable as a recipe dependency.
# For example,
#   `my_target: | _program_awk`
# will fail before running the target named `my_target` if the command `awk` is
# not found on the system path.
_program_%: export MAKE_TARGET=$@
_program_%: FORCE
	_=$(or $(shell which $* 2> /dev/null),$(error `$*` command not found. Please install `$*` and try again))

# Helper target for checking required environment variables.
#
# For example,
#   `my_target`: | _verify_FOO`
#
# will fail before running `my_target` if the variable `FOO` is not declared.
_verify_%: export MAKE_TARGET=$@
_verify_%: FORCE
	_=$(if $($*),,$(error `$*` is not defined or is empty))

# text manipulation helpers
_awk_case = $(shell echo | awk '{ print $(1)("$(2)") }')
lc = $(call _awk_case,tolower,$(1))
uc = $(call _awk_case,toupper,$(1))

# $(info BUILD_DIR=$(BUILD_DIR))
$(BUILD_DIR)::
	mkdir -p $@

## Make it so
ship-it::


# ---- Logr ----
# usage example : $(logr) "message"

LOG_PREFIX ?= -->

creset=\e[0m
#bold
cbold=\e[1m
#underline
culine=\e[4m
cgreen=\e[32m
cblue=\e[34m
ccyan=\e[36m
cmagenta=\e[35m
cred=\e[31m
cyellow=\e[33m

#bold
cblueB=\e[1;34m
ccyanB=\e[1;36m
cmagentaB=\e[1;35m
credB=\e[1;31m

# print target wtih check mark
define _finished =
printf '$(cgreen)✔︎ $@ finished $(creset)\n'
endef

# target wtih check mark
define logr.done =
printf '$(cgreen)✔︎ [$@] finished %s $(creset)\n'
endef

define logr =
printf '$(ccyan)$(LOG_PREFIX) %s $(creset)\n'
endef

define logr.info =
printf '$(ccyan)$(LOG_PREFIX) %s $(creset)\n'
endef

define logr.warn =
printf '$(cyellow)$(LOG_PREFIX) %s $(creset)\n'
endef

define logr.error =
printf '$(credB)$(LOG_PREFIX) %s $(creset)\n'
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

# downloads a tar.gz and expands it into the specifed dir under SHIPKIT_INSTALLS
# $1 - the url to the tar.gz
# $2 - where to put it
define download_tar
	$(logr) "download and untar to $(2)"
	install_dir=$(SHIPKIT_INSTALLS)/$(2)
	mkdir -p $$install_dir
	$(DOWNLOADER) $(DOWNLOAD_FLAGS) "$(1)" | tar zxf - -C $$install_dir --strip-components 1
endef

# when need to git clone will put under SHIPKIT_INSTALLS
# $1 - the clone url
# $2 - where to put it
define download_git
	$(logr) "git clone to $(SHIPKIT_INSTALLS)/$(2)"
	install_dir=$(SHIPKIT_INSTALLS)/$(2)
	git clone $(1) $(SHIPKIT_INSTALLS)/$(2)
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
	$(logr) "OS_NAME $(OS_NAME)"
	$(logr) "OS_ARCH $(OS_ARCH)"
	$(logr.warn) "OS_CPU $(OS_CPU)"
	$(logr.error) "error $(OS_CPU)"
	$(_finished)
