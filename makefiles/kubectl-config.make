# -------------
# configures kubectl based on vars
# -------------
kube_tools := $(SHIPKIT_BIN)/kube_tools

# creates kubectl config, used in primarily CI, same sure $K8_SERVER $K8_USER $K8_TOKEN env vars are setup
kubectl.config: | _verify_K8_SERVER _verify_K8_USER _verify_K8_TOKEN
	kubectl config set-cluster ranch-dev --server="$(K8_SERVER)"
	kubectl config set-credentials "$(K8_USER)" --token="$(K8_TOKEN)"
	kubectl config set-context "ranch-dev" --user="$(K8_USER)" --cluster="ranch-dev"
	kubectl config use-context "ranch-dev"
	$(_finished)

.PHONY: kubectl.config

# list the contexts
kubectl.get-contexts:
	kubectl config get-contexts

# use a context
kubectl.use-context.%:
	kubectl config use-context $*

