# -------------
# spring and grails targets for building docker
# Makefile-core.make should be included before this
# -------------
# depends on gradle-tools that should be include before this

gw := ./gradlew
build_docker_dir := $(BUILD_DIR)/docker

# rm -rf build/docker
docker.clean-build:
	rm -rf $(build_docker_dir)/*

$(build_docker_dir):
	mkdir -p $@

DOCKER_DEPLOY_SOURCES := $(wildcard $(APP_DOCKER_SRC)/*)

# sets up the build/docker by copying in the src/deploy files, copy the executable jar
# then 'explodes' or unjars the executable jar so dockerfile can iterate on build changes
# layering docker see https://blog.jdriven.com/2019/08/layered-spring-boot-docker-images/
$(BUILD_DIR)/docker/Dockerfile: $(build_docker_dir) $(DOCKER_DEPLOY_SOURCES) | _verify_APP_JAR
	$(logr) "copy Dockerfile"
	rm -rf $(build_docker_dir)/*
	cp -r $(APP_DOCKER_SRC)/. $(build_docker_dir);

# copies the jar in and explodes it
$(BUILD_DIR)/docker/app.jar: $(APP_JAR) build/docker/Dockerfile | _verify_APP_JAR
	$(logr) "copy app.jar"
	cp $(APP_JAR) $(build_docker_dir)/app.jar
	cd $(build_docker_dir)
	"$$JAVA_HOME"/bin/jar -xf app.jar

# does the docker build
$(BUILD_DIR)/docker_built_$(APP_KEY): build/docker/app.jar | _verify_APP_DOCKER_URL
	docker build -t $(APP_DOCKER_URL) $(build_docker_dir)/.
	touch $(BUILD_DIR)/docker_built_$(APP_KEY)

.PHONY: docker.app-build
# for easier testing of the docker build
docker.app-build: $(BUILD_DIR)/docker_built_$(APP_KEY)

# stamp to track if it was deployed
build/docker_push_$(APP_KEY): $(BUILD_DIR)/docker_built_$(APP_KEY) | _verify_APP_DOCKER_URL
	if [ "$(dry_run)" ]; then
		echo "🌮 dry_run ->  docker push $(APP_DOCKER_URL)"
	else
		docker push $(APP_DOCKER_URL)
		touch $(BUILD_DIR)/docker_push_$(APP_KEY)
	fi

.PHONY: docker.app-push
## builds and deploys whats in the src/deploy for the APP_DOCKER_URL to docker hub
docker.app-push: $(BUILD_DIR)/docker_push_$(APP_KEY)

APP_COMPOSE_FILE ?= $(build_docker_dir)/docker-compose.yml
APP_COMPOSE_CMD := APP_DOCKER_URL=$(APP_DOCKER_URL) APP_NAME=$(APP_NAME) docker compose -p $(APP_NAME)_servers -f $(APP_COMPOSE_FILE)
APP_COMPOSE_CLEAN_FLAGS ?= --volumes --remove-orphans

## docker compose for the runnable jar, follow with a docker cmd such as up, down, shell or pull
docker.app: | _verify-DOCKER_CMD
	$(MAKE) docker.app-$(DOCKER_CMD)

# docker compose up for APP_JAR
docker.app-up: build/docker_built_$(APP_KEY)
	$(APP_COMPOSE_CMD) up -d

# stops the docker APP_JAR for docker-compose.yml
docker.app-down:
	$(APP_COMPOSE_CMD) down $(APP_COMPOSE_CLEAN_FLAGS)

docker.app-shell: docker.app-up
	docker exec -it $(APP_NAME) bash -l

# Implement in main makefile
# ship.docker:: docker.app-build docker.app-push
# 	$(logr.done)
