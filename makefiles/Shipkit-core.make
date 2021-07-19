# functions and targets for logging, downloading and OS detection
# Imported into core shipkit.make

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

test-logging-defs: FORCE
	$(call log, log OS_NAME $(OS_NAME))
	$(call _log, _log OS_ARCH $(OS_ARCH))
	$(call _warn, _warn OS_CPU $(OS_CPU))
	$(call _error, sample _error $(OS_CPU))
