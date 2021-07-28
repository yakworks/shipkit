
PAGES_DEPLOY_TPL ?= $(SHIPKIT_DIR)/k8s/docmark-pages-deploy.tpl.yml

pages.delete-k8s-deployment:
	kubectl delete deployment,ingress --selector="pages=$(PAGES_APP_KEY)" --namespace="$(PAGES_KUBE_NAMESPACE)"

## apply docmark-pages-deploy.tpl kubectl to deploy site to k8s
pages.deploy-k8s: pages.delete-k8s-deployment
	${kube_tools} apply_tpl $(PAGES_DEPLOY_TPL)


# TODO at some point we want to look at publishing snapshot version of docs like we once did?
# NOT_SNAPSHOT := $(if $(IS_SNAPSHOT),,true)
# ifneq (,$(and $(RELEASABLE_BRANCH),$(NOT_SNAPSHOT)))

.PHONY: ship.k8s-pages

ifeq (true,$(IS_RELEASABLE))

ship.k8s-pages:
	$(MAKE) pages.deploy-k8s
	echo $@ success
else

ship.k8s-pages:
	echo "*** $@ IS_RELEASABLE=false as this is either a snapshot or its not on a releasable branch ***"

endif
