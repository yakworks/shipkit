
# DOCKER_CMD verbs

# MAKECMDGOALS has the list of all target goals that are passed into make cmd
ifeq (up,$(filter up,$(MAKECMDGOALS)))
  DOCKER_CMD = up
else ifeq (down,$(filter down,$(MAKECMDGOALS)))
  DOCKER_CMD = down
else ifeq (shell,$(filter shell,$(MAKECMDGOALS)))
  DOCKER_CMD = shell
else ifeq (pull,$(filter pull,$(MAKECMDGOALS)))
  DOCKER_CMD = pull
endif

# dummy targets so we dont get the make[1]: Nothing to be done for `xxx'.
docker_verb_targets = up down shell pull
.PHONY: $(docker_verb_targets)
$(docker_verb_targets):
	@:

# verifies the command verb
_verify-DOCKER_CMD: FORCE
	@_=$(if $(DOCKER_CMD),,$(error docker target must be followed by the verb such as up, down, shell or pull))

# double $$ means esacpe it and send to bash as a single $
# login to docker hub using whats in the env vars $DOCKERHUB_USER $DOCKERHUB_PASSWORD
dockerhub-login: FORCE
	echo "$(DOCKERHUB_PASSWORD)" | docker login -u "$(DOCKERHUB_USER)" --password-stdin
