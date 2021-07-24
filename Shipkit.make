# this grabs the path that this Shipkit.make is in.
export SHIPKIT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
export SHIPKIT_BIN := $(SHIPKIT_DIR)/bin
export SHIPKIT_MAKEFILES := $(SHIPKIT_DIR)/makefiles
# Default opinionated config & flags for make
include $(SHIPKIT_MAKEFILES)/Shipkit-flags.make
# the juice
include $(SHIPKIT_MAKEFILES)/env-goals.make
# the juice
include $(SHIPKIT_MAKEFILES)/Shipkit-main.make


