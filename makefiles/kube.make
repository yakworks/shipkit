# -------------
# kubernetes targets
# -------------
kube_tools := $(SHIPKIT_BIN)/kube_tools

.PHONY: kube-clean kube-config kube-create-ns kube-port-forward

## removes everything with the app=$(APP_KEY) under $(APP_KUBE_NAMESPACE)
kube-clean: | _verify_APP_KUBE_NAMESPACE
	kubectl delete deployment,svc,configmap,ingress --selector="app=$(APP_KEY)" --namespace="$(APP_KUBE_NAMESPACE)"

## creates the APP_KUBE_NAMESPACE namespace if its doesn't exist
kube-create-ns: | _verify_APP_KUBE_NAMESPACE
	$(kube_tools) kubeCreateNamespace $(APP_KUBE_NAMESPACE)

## runs kubectl port-forward to the $(KUBE_DB_SERVICE_NAME)
kube-port-forward:
	kubectl port-forward --namespace=$(APP_KUBE_NAMESPACE) --address 0.0.0.0 service/$(KUBE_DB_SERVICE_NAME) 1$(DB_PORT):$(DB_PORT)
