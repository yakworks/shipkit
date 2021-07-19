# tell shipkit where the main build.sh is, not used in test
# build.sh := ./build.sh
# If setting any vars needed for the $(shell init_vars..) in Shipkit.make then track the MAKE_VARS so those dont get added
# if not git is installed then need to add the PROJECT_FULLNAME, much easier to add a build.sh and do it there
# export PROJECT_FULLNAME = yakworks/shipkit
# BUILD_VARS = PROJECT_FULLNAME # need this in order for it to build what vars get passed the $(shell)
# core include, creates the makefile.env for the BUILD_VARS that evrything else depends on
include Shipkit.make
include $(SHIPKIT_MAKEFILES)/docker.make

# --- Dockers ---
docker_tools := $(SHIPKIT_BIN)/docker_tools
DOCK_SHELL_URL = yakworks/builder:bash-make

## docker shell for testing
docker-shell:
	$(docker_tools) dockerStart shipkit-shell -it \
	  -v `pwd`:/project:delegated  \
	  $(DOCK_SHELL_URL) /bin/bash

# --- Testing ---
BATS_VERSION ?= 1.3.0
# BATS_TESTS   ?= . 3>&1
BATS_TESTS   ?= tests
BATS_OPTS    ?=
BATS_DIR     ?= $(BUILD_DIR)/bats
BATS_URL     := https://github.com/bats-core/bats-core/archive/refs/tags/v$(BATS_VERSION).tar.gz
BATS_EXE     := $(BATS_DIR)/bin/bats

test: $(BATS_EXE)
	$(BATS_EXE) $(BATS_OPTS) $(BATS_TESTS)
	# $(BATS) $(BATS_OPTS) $(BATS_TESTS)
.PHONY: test

$(BATS_EXE):
	@mkdir -p $(BATS_DIR)
	$(call download,$(BATS_URL),tar zxf - -C $(BATS_DIR) --strip-components 1)
	touch $(BATS_EXE)

clean::
	rm -rf $(BATS_DIR)

oneshell-test:
	@ FOO=bar
	if [ "$$FOO" ]; then
		echo $$FOO
	fi

# test: install-test
# 	@export PATH="build/bats-core/bin:$$PATH"; \
# 	bats . 3>&1
