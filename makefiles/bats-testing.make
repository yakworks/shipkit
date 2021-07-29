# goals to install bats and support and assert

# --- BATS Testing ---
BATS_VERSION ?= 1.3.0
# BATS_TESTS   ?= . 3>&1

BATS_TEST_DIR ?= tests
# what tests to run under BATS_TEST_DIR, dot means all, use glob wild cards
TESTS ?= .
BATS_OPTS ?=
BATS_GH_URL      := https://github.com/bats-core
BATS_URL         := $(BATS_GH_URL)/bats-core/archive/refs/tags/v$(BATS_VERSION).tar.gz
BATS_SUPPORT_URL := $(BATS_GH_URL)/bats-support/archive/refs/tags/v0.3.0.tar.gz
BATS_ASSERT_URL  := $(BATS_GH_URL)/bats-assert/archive/refs/tags/v2.0.0.tar.gz
BATS_EXE         := $(SHIPKIT_INSTALLS)/bats/bin/bats

## runs the bat tests
test-bats: $(BATS_EXE)
	$(BATS_EXE) $(BATS_OPTS) -f $(TESTS) $(BATS_TEST_DIR)
	# echo "--- bashify tests ---"
	$(BATS_EXE) $(BATS_OPTS) -f $(TESTS) $(BATS_TEST_DIR)/bashify

.PHONY: test-bats

$(BATS_EXE):
	$(call download_tar,$(BATS_URL),bats) # Installs bats-core
	$(call download_tar,$(BATS_SUPPORT_URL),bats-support) # Installs bats-support
	$(call download_tar,$(BATS_ASSERT_URL),bats-assert) # Installs bats-assert
	touch $(BATS_EXE)
