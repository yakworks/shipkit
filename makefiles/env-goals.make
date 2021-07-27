# ----- setup the BUILD_ENV based on target goals  -------
# BUILD_ENV is used to to pass to gradle/liquibase and to build the database name etc....
BUILD_ENV = dev
# MAKECMDGOALS has the list of all target goals that are passed into make cmd
ifeq (test-env,$(filter test-env,$(MAKECMDGOALS)))
  BUILD_ENV = test
else ifeq (seed,$(filter seed,$(MAKECMDGOALS)))
  BUILD_ENV = seed
endif

# dummy targets so we dont get the make[1]: Nothing to be done for `xxx'.
dummy_targets = dev seed test-env
.PHONY: $(dummy_targets)
$(dummy_targets):
	@:
# ----- setup the specified database based on phony target we pass in

# we can do `make build dev sqlserver` or `make build dev sqlserver`
# the main Makefile should specify the default
ifdef DB

  DBMS ?= mysql
  ifeq (sqlserver,$(filter sqlserver,$(MAKECMDGOALS)))
    DBMS = sqlserver
  else ifeq (oracle,$(filter oracle,$(MAKECMDGOALS)))
    DBMS = oracle
  else ifeq (h2,$(filter h2,$(MAKECMDGOALS)))
    DBMS = h2
  endif
  BUILD_VARS += DBMS

  # dummy targets so we dont get the make[1]: Nothing to be done for `xxx'.
  dummy_db_targets = mysql sqlserver postgres h2
  .PHONY: $(dummy_db_targets)
  $(dummy_db_targets):
	@:

#   $(info DB active with flavor $(DBMS))

endif # end DB check
