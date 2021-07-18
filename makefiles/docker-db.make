# -------------
# Helper tasks to start and connect the database dockers for dev and building
# -------------

#----- DB targets -------
.PHONY: db-start db-wait db-down

## starts the DOCK_DB_BUILD_NAME db if its not started yet, unless USE_DOCKER_DB_BUILDER=false
db-start: builder-network
	$(build.sh) db-start $(DB_VENDOR)

# runs a wait-for script that blocks until db mysql or sqlcmd succeeds
db-wait:
	@$(DockerDbExec) $(build.sh) wait_for_$(DBMS) $(DB_HOST) $(DB_PASSWORD)

db-down: ## stop and remove the docker DOCK_DB_BUILD_NAME
	@$(build.sh) dockerRemove $(DOCK_DB_BUILD_NAME)

start-db: ## calls db-start if USE_DB_BUILDER=true
	@if [ "$(USE_DOCKER_DB_BUILDER)" == "true" ]; then \
	  $(MAKE) $(DBMS) db-start; \
	fi;

db-restart: db-down ## restart the db
	$(MAKE) $(DBMS) db-start

restart-db: db-restart ## alias to db-restart, restarts the db

db-pull: db-down ## pulls latest nine-db from dock9 docker hub
	docker pull $(DOCKER_DB_URL)


#----- clean up-------
docker-remove-all: builder-remove ## runs `make db-down` for sqlserver and mysql and
	$(MAKE) mysql db-down
	$(MAKE) sqlserver db-down
