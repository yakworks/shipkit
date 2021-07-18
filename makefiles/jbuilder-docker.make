# -------------
# targets for starting docker compose for the builder
# -------------

# the jdk builder8
JBUILDER_NAME := $(PROJECT_NAME)_jbuilder
JBUILDER_COMPOSE_FILE ?= ./jbuilder-compose.yml
JBUILDER_COMPOSE_CMD := JBUILDER_NAME=$(JBUILDER_NAME) docker compose -p $(JBUILDER_NAME)_servers -f $(JBUILDER_COMPOSE_FILE)

## docker compose for jbuilder-compose.yml, follow with the docker cmd such as up, down, shell or pull
docker-jbuilder: | _verify-DOCKER_CMD
	$(MAKE) jbuilder-$(DOCKER_CMD)

# docker compose up on jbuilder-compose.yml
jbuilder-up:
	$(JBUILDER_COMPOSE_CMD) up -d

# docker compose down on jbuilder-compose.yml
jbuilder-down:
	$(JBUILDER_COMPOSE_CMD) down --volumes --remove-orphans

# shell into the jdk docker builder
jbuilder-shell: jbuilder-up
	docker exec -it $(JBUILDER_NAME) bash -l

# pulls the latest images in jbuilder-compose.yml
jbuilder-pull:
	$(JBUILDER_COMPOSE_CMD) pull
