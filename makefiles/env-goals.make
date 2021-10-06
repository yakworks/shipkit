# ----- setup the BUILD_ENV based on target goals  -------
# BUILD_ENV is used to to pass to gradle/liquibase and to build the database name etc....
export BUILD_ENV = dev
# MAKECMDGOALS has the list of all target goals that are passed into make cmd
ifeq (testenv,$(filter testenv,$(MAKECMDGOALS)))
  BUILD_ENV = test
else ifeq (testing,$(filter testing,$(MAKECMDGOALS)))
  BUILD_ENV = test
else ifeq (test_env,$(filter test_env,$(MAKECMDGOALS)))
  BUILD_ENV = test
else ifeq (prod,$(filter prod,$(MAKECMDGOALS)))
  BUILD_ENV = prod
endif

# dummy targets so we dont get the make[1]: Nothing to be done for `xxx'.
dummy_targets = dev prod testenv test_env testing
.PHONY: $(dummy_targets)
$(dummy_targets):
	@:
# ----- setup the specified database based on phony target we pass in

# we can do `make build dev sqlserver` or `make build dev sqlserver`
# the main Makefile should specify the default
ifdef DB

  export DBMS ?= mysql
  ifeq (sqlserver,$(filter sqlserver,$(MAKECMDGOALS)))
   DBMS = sqlserver
  else ifeq (oracle,$(filter oracle,$(MAKECMDGOALS)))
   DBMS = oracle
  else ifeq (h2,$(filter h2,$(MAKECMDGOALS)))
   DBMS = h2
  else ifeq (mysql,$(filter mysql,$(MAKECMDGOALS)))
   DBMS = mysql
  else ifeq (postgresql,$(filter postgresql,$(MAKECMDGOALS)))
   DBMS = postgresql
  else ifeq (postgres,$(filter postgres,$(MAKECMDGOALS)))
   DBMS = postgresql
  endif

  # dummy targets so we dont get the make[1]: Nothing to be done for `xxx'.
  dummy_db_targets = postgresql postgres mysql sqlserver oracle h2
  .PHONY: $(dummy_db_targets)
  $(dummy_db_targets):
	@:

#   $(info DB active with flavor $(DBMS))

endif # end DB check
