# tell shipkit where the main build.sh is
build.sh := ./build.sh
# core include, creates the makefile.env for the BUILD_VARS that evrything else depends on
include ../shipkit.make

BATS_VERSION ?= 1.3.0
BATS_TESTS   ?= . 3>&1
BATS_OPTS    ?=
BATS_DIR     ?= $(BUILD_DIR)/bats
BATS_URL     := https://github.com/bats-core/bats-core/archive/refs/tags/v$(BATS_VERSION).tar.gz
BATS_RUN     := $(BATS_DIR)/bin/bats

test: $(BATS_RUN)
	$(BATS_RUN) $(BATS_OPTS) $(BATS_TESTS)
	# $(BATS) $(BATS_OPTS) $(BATS_TESTS)
.PHONY: test

$(BATS_DIR):
	@mkdir -p $@

$(BATS_RUN): | $(BATS_DIR)
	$(call download,$(BATS_URL),tar zxf - -C $(BATS_DIR) --strip-components 1)
	@touch $(BATS_RUN)

clean::
	rm -rf $(BATS_DIR)

# install-test:
# 	@if [ ! -d "build/bats-core" ]; then \
# 	git clone --depth 1 -b v1.3.0 https://github.com/bats-core/bats-core.git build/bats-core; \
# 	fi

# test: install-test
# 	@export PATH="build/bats-core/bin:$$PATH"; \
# 	bats . 3>&1