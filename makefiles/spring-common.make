# -------------
# Spring/grails collection of includes for common needs to cut down on the include noise in main makefile
# For a spring project that has a docker builder, docs,
# -------------
# --- helper makefiles ---
include $(SKIT_MAKEFILES)/secrets.make
include $(SKIT_MAKEFILES)/git-tools.make
include $(SKIT_MAKEFILES)/docker.make
include $(SKIT_MAKEFILES)/kubectl-config.make
include $(SKIT_MAKEFILES)/kube.make
include $(SKIT_MAKEFILES)/jbuilder-docker.make
include $(SKIT_MAKEFILES)/spring-gradle.make
include $(SKIT_MAKEFILES)/spring-docker.make
include $(SKIT_MAKEFILES)/circle.make
include $(SKIT_MAKEFILES)/docmark.make
