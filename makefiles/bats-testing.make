# goals to install bats and support and assert

# --- BATS Testing ---
BATS_VERSION ?= 1.7.0
# BATS_TESTS   ?= . 3>&1

BATS_TEST_DIR ?= tests
# what tests to run under BATS_TEST_DIR, dot means all, use glob wild cards
BATS_FILTER ?= .
TESTS ?=
# -r says to find tests recursively in subdirs
BATS_OPTS ?= -r
BATS_GH_URL      := https://github.com/bats-core
BATS_URL         := $(BATS_GH_URL)/bats-core/archive/refs/tags/v$(BATS_VERSION).tar.gz
BATS_SUPPORT_URL := $(BATS_GH_URL)/bats-support/archive/refs/tags/v0.3.0.tar.gz
BATS_ASSERT_URL  := $(BATS_GH_URL)/bats-assert/archive/refs/tags/v2.0.0.tar.gz
BATS_EXE         := $(SHIPKIT_INSTALLS)/bats/bin/bats

export BATS_LIB_PATH=$(abspath $(BUILD_DIR)/installs)

# runs the bat tests. To run a single test do 'make test-bats TESTS=someFile*'
test-bats: $(BATS_EXE)
	$(BATS_EXE) $(BATS_OPTS) -f $(BATS_FILTER) $(BATS_TEST_DIR)/$(TESTS)
	# $(logr) " Core tests"
	# $(BATS_EXE) $(BATS_OPTS) -f $(BATS_FILTER) $(BATS_TEST_DIR)/core/$(TESTS)

.PHONY: test-bats

# example of running a single test file
test-bats-single:
	$(BATS_EXE) $(BATS_OPTS) $(BATS_TEST_DIR)/utils_trim.bats

$(BATS_EXE):
	$(call download_tar,$(BATS_URL),bats) # Installs bats-core
	$(call download_tar,$(BATS_SUPPORT_URL),bats-support) # Installs bats-support
	$(call download_tar,$(BATS_ASSERT_URL),bats-assert) # Installs bats-assert
	touch $(BATS_EXE)
