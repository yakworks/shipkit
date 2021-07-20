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

PAGES_DEPLOY_TPL ?= $(SHIPKIT_DIR)/k8s/docmark-pages-deploy.tpl.yml

pages-delete-deployment:
	@kubectl delete deployment,ingress --selector="pages=$(PAGES_APP_KEY)" --namespace="$(PAGES_KUBE_NAMESPACE)"

## apply docmark-pages-deploy.tpl kubectl to deploy site to kubernetes cluster
pages-deploy: pages-delete-deployment
	@${kube_tools} kubeApplyTpl $(PAGES_DEPLOY_TPL)
