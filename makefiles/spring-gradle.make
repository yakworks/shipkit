# -------------
# Common gradle tasks and helpers for spring/grails.
# Its opionated based on a springboot or grails app and assumes that codenarc and spotlessCheck are installed
# Makefile-core.make should be imported before this
# -------------
gw := ./gradlew
spring_gradle := $(SHIPKIT_BIN)/spring_gradle

## runs codenarc and spotless
lint::
	$(gw) spotlessCheck codenarcMain

## Run the lint and test suite with ./gradlew check
check::
	$(gw) check

clean::
	$(gw) clean

compile::
	$(gw) classes

## builds jars, gradle assemble
build::
	$(gw) assemble

testArg := $(if $(tests),--tests *$(tests)*, )

test::
	$(gw) test integrationTest

## unit tests with gradle test, tests=PartialTestName will pass --tests *PartialTestName*
test-unit::
	$(gw) test $(testArg)

## integration and functional tests, tests=PartialTestName will pass --tests *PartialTestName*
test-e2e::
	$(gw) integrationTest $(testArg)

## publish the libs
publish::
	$(gw) publish

# verifies the snapshot is set
_verify-snapshot: FORCE
	@_=$(if $(IS_SNAPSHOT),,$(error set snapshot=true in version properties))

## build snapshot(s) into you local maven
snapshot:: | _verify-snapshot
	$(gw) snapshot

# here so we can depend on it being there and if not firing assemble
$(APP_JAR):
	$(gw) assemble

## java runs the APP_JAR
start-jar: $(APP_JAR)
	java -server -Xmx3048m -XX:MaxMetaspaceSize=256m -jar $(APP_JAR)

.PHONY: resolve-dependencies merge-test-results

# calls `gradlew resolveConfigurations` to download deps without compiling, used mostly for CI cache
resolve-dependencies:
	$(gw) resolveConfigurations --no-daemon

# on multi-project gradles this will merges test results into one spot for a CI build
merge-test-results: FORCE | _verify_PROJECT_SUBPROJECTS
	$(spring_gradle) merge_test_results "$(PROJECT_SUBPROJECTS)"

.PHONY: publish-lib
# empty targets so make doesn't blow up when not a RELEASABLE_BRANCH
# publish the library jar, gradle publish if a gradle project
publish-lib:

ifdef RELEASABLE_BRANCH

 publish-lib:
	@if [ "$(IS_SNAPSHOT)" ]; then echo "publishing SNAPSHOT"; else echo "publishing release"; fi
	./gradlew publish

endif # end RELEASABLE_BRANCH
