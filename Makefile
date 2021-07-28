# tell shipkit where the main build.sh is, not used in test
# build.sh := ./build.sh
# If setting any vars needed for the $(shell init_vars..) in Shipkit.make then track the MAKE_VARS so those dont get added
# if not git is installed then need to add the PROJECT_FULLNAME, much easier to add a build.sh and do it there
# export PROJECT_FULLNAME = yakworks/shipkit
# BUILD_VARS = PROJECT_FULLNAME # need this in order for it to build what vars get passed the $(shell)
# core include, creates the makefile.env for the BUILD_VARS that evrything else depends on
include Shipkit.make
include $(SHIPKIT_MAKEFILES)/base-build.make
include $(SHIPKIT_MAKEFILES)/docker.make
include $(SHIPKIT_MAKEFILES)/secrets.make
include $(SHIPKIT_MAKEFILES)/git-tools.make
include $(SHIPKIT_MAKEFILES)/ship-version.make
include $(SHIPKIT_MAKEFILES)/circle.make
include $(SHIPKIT_MAKEFILES)/bats-testing.make

# -- Variables ---
export BOT_EMAIL ?= 9cibot@9ci.com
# can be set here but best to export it in shell so make's $(shell ) function can pick it up
export LOGR_DEBUG_ENABLED := true

# --- Dockers ---
docker_tools := $(SHIPKIT_BIN)/docker_tools
DOCK_SHELL_URL = yakworks/builder:bash-make

## docker shell for testing
docker.shell:
	$(docker_tools) start shipkit-shell -it \
	  -v `pwd`:/project:delegated  \
	  $(DOCK_SHELL_URL) /bin/bash

SHELLCHECK_DIRS ?= bin makefiles
lint::
	$(BASHIFY_PATH)/shellchecker lint $(SHELLCHECK_DIRS)

## fixes what is can using shellcheck diffs and git apply
lint.fix:
	$(BASHIFY_PATH)/shellchecker lint_fix $(SHELLCHECK_DIRS)

## Run the lint and tests
check:: lint test

## removes the BUILD_DIR
clean::
	rm -rf $(BUILD_DIR)

## runs the bashify tests
test.bashify: $(BATS_EXE)
	$(BATS_EXE) $(BATS_OPTS) -f $(TESTS) $(BATS_TEST_DIR)/bashify

## runs all BAT tests
test.unit:: test-bats test-bashify

## runs all BAT tests
test:: test-bats

## NA runs integration/e2e tests
test.e2e::

## NA builds the libs
build::

define success_msg =
echo $@ success
endef

foo:
	echo foo
	$(success_msg)
