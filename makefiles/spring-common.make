# -------------
# Spring/grails collection of includes for common needs to cut down on the include noise in main makefile
# For a spring project that has a docker builder, docs,
# -------------
# --- helper makefiles ---
# include boilerplate to set BUILD_ENV and DB from targets
include $(SHIPKIT_MAKEFILES)/env-db.make

include $(SHIPKIT_MAKEFILES)/secrets.make
include $(SHIPKIT_MAKEFILES)/git-tools.make
include $(SHIPKIT_MAKEFILES)/docker.make
include $(SHIPKIT_MAKEFILES)/kubectl-config.make
include $(SHIPKIT_MAKEFILES)/kube.make
include $(SHIPKIT_MAKEFILES)/jbuilder-docker.make
include $(SHIPKIT_MAKEFILES)/spring-gradle.make
include $(SHIPKIT_MAKEFILES)/spring-docker.make
include $(SHIPKIT_MAKEFILES)/docmark.make
include $(SHIPKIT_MAKEFILES)/ship-version.make
