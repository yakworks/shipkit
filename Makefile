
# If setting any vars needed for the $(shell init_vars..) in Shipkit.make then track the MAKE_VARS so those dont get added
# if not git is installed then need to add the PROJECT_FULLNAME, much easier to add a build.yml and do it there
# export PROJECT_FULLNAME = yakworks/shipkit
# BUILD_VARS = PROJECT_FULLNAME # need this in order for it to build what vars get passed the $(shell)
# core include, creates the makefile.env for the BUILD_VARS that evrything else depends on
include Shipkit.make
include $(SHIPKIT_MAKEFILES)/vault.make
include $(SHIPKIT_MAKEFILES)/base-build.make
include $(SHIPKIT_MAKEFILES)/docker.make
include $(SHIPKIT_MAKEFILES)/docmark.make
include $(SHIPKIT_MAKEFILES)/git-tools.make
include $(SHIPKIT_MAKEFILES)/ship-version.make
include $(SHIPKIT_MAKEFILES)/circle.make
include $(SHIPKIT_MAKEFILES)/bats-testing.make
include $(SHIPKIT_MAKEFILES)/kube.make
include $(SHIPKIT_MAKEFILES)/kubectl-config.make

# -- Variables ---
export BOT_EMAIL ?= 9cibot@9ci.com
export BOT_SIGN_COMMITS = true
export VAULT_REPO = 9ci/vault
# after release, will set version.properties back to snapshot=true
# export VERSION_SET_SNAPSHOT = true
export RELEASE_RESET_FLAG = true

# can be set here but best do it on command line with make
# export LOGIT_DEBUG_ENABLED := true

# --- Dockers ---
docker_tools := $(SHIPKIT_BIN)/docker_tools
DOCK_SHELL_URL = yakworks/builder:base
DOCK_SHELL_DEB_URL = yakworks/bullseye:base

## docker shell for testing
docker.shell:
	$(docker_tools) start shipkit-shell -it \
	  -v `pwd`:/project:delegated  \
	  $(DOCK_SHELL_URL) /bin/bash

# docker shelk with bullseye debian image
docker.shell.deb:
	$(docker_tools) start shipkit-shell -it \
	  -v `pwd`:/project:delegated  \
	  $(DOCK_SHELL_DEB_URL) /bin/bash

SHELLCHECK_DIRS ?= bin makefiles
lint:: lint.makefiles
	$(SHIPKIT_BIN)/shellchecker lint $(SHELLCHECK_DIRS)

## fixes what is can using shellcheck diffs and git apply
lint.fix:
	$(SHIPKIT_BIN)/shellchecker lint_fix $(SHELLCHECK_DIRS)

# checks the makefiles
lint.makefiles:
	$(SHIPKIT_BIN)/makechecker lint makefiles

## Run the lint and tests
check:: lint test

## removes the BUILD_DIR
clean::
	rm -rf $(BUILD_DIR)

## runs all BAT tests. to run tests matching a regex do `make test-bats TESTS=test_names.*`
test:: test-bats

## NA builds the libs
build::


build/usage/is.md: bin/is.sh
	mkdir -p $(@D)
	./bin/bashdoc/shdocs.sh file $< $@

## generate usage docs from bin
docs.generate:
	shopt -s globstar
	awk -v MULTI_FILE=1 -v SHOW_SRC=1 -f ./bin/shdoc/shdoc.awk -f ./bin/shdoc/shdoc_fns.awk bin/* > docs/USAGE.md
