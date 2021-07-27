# -------------
# Helper tasks to start and connect the database dockers for dev and building
# -------------

docker_tools := $(SHIPKIT_BIN)/docker_tools

#----- DB targets -------
.PHONY: db-start db-wait db-down

## starts the DOCK_DB_BUILD_NAME db if its not started yet
db.start: db.create-network
	# ACCEPT_EULA is for sql server, just an env var so won't matter that its set for others
	$(docker_tools) docker.start "$(DOCK_DB_BUILD_NAME)" -d \
		--network builder-net \
		-v "`pwd`":/project \
		-w /project \
		-e ACCEPT_EULA=Y \
		-p "$(DB_PORT)":"$(DB_PORT)"  \
		-e "$(PASS_VAR_NAME)"="$(DB_PASSWORD)" \
		"$(DOCKER_DB_URL)"

## alias for db.start
start.db: db.start

db.create-network:
	$(docker_tools) docker.create_network $(APP_NAME)

# runs a wait-for script that blocks until db mysql or sqlcmd succeeds
db.wait:
	# TODO not working
	$(DockerDbExec) $(build.sh) wait_for_$(DBMS) $(DB_HOST) $(DB_PASSWORD)

## stop and remove the docker DOCK_DB_BUILD_NAME
db.down:
	$(docker_tools) docker.remove $(DOCK_DB_BUILD_NAME)

## restart the db
db.restart: db.down
	$(MAKE) $(DBMS) "db.start"

## stop and remove the docker DOCK_DB_BUILD_NAME
db.pull: db.down ## pulls latest nine-db from dock9 docker hub
	docker pull $(DOCKER_DB_URL)


#----- clean up-------
# runs `make db-down` for sqlserver and mysql and
docker.remove-all: builder-remove
	$(MAKE) mysql db-down
	$(MAKE) sqlserver db-down
