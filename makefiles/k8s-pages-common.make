# -------------
# Pages collection of includes for common needs to cut down on the include noise in main makefile
# for a project that is only for docs this should be all that is needed to include
# -------------
include $(SHIPKIT_MAKEFILES)/secrets.make
include $(SHIPKIT_MAKEFILES)/git-tools.make
include $(SHIPKIT_MAKEFILES)/kubectl-config.make
include $(SHIPKIT_MAKEFILES)/circle.make
include $(SHIPKIT_MAKEFILES)/docker.make
include $(SHIPKIT_MAKEFILES)/docmark.make
include $(SHIPKIT_MAKEFILES)/ship-k8s-pages.make
