# -------------
# Spring/grails collection of includes for common needs to cut down on the include noise in main makefile
# For a spring project that has a docker builder, docs,
# -------------
# --- helper makefiles ---
include $(SHIPKIT_MAKEFILES)/git-tools.make
include $(SHIPKIT_MAKEFILES)/docker.make
include $(SHIPKIT_MAKEFILES)/kubectl-config.make
include $(SHIPKIT_MAKEFILES)/kube.make
include $(SHIPKIT_MAKEFILES)/jdk-docker.make
include $(SHIPKIT_MAKEFILES)/gradle-tools.make
include $(SHIPKIT_MAKEFILES)/spring-docker.make
include $(SHIPKIT_MAKEFILES)/docmark.make
include $(SHIPKIT_MAKEFILES)/ship-version.make
