# -------------
# Common gradle tasks and helpers for spring/grails.
# Its opionated based on a springboot or grails app and assumes that codenarc and spotlessCheck are installed
# Makefile-core.make should be imported before this
# -------------
gradlew ?= ./gradlew
gradle_tools := $(SHIPKIT_BIN)/gradle_tools
gradle_properties ?= gradle.properties
build_gradle ?= build.gradle


## runs codenarc and spotless
lint::
	$(gradlew) spotlessCheck codenarcMain

## Run the lint and test suite with ./gradlew check
check::
	$(gradlew) check

clean::
	$(gradlew) clean

compile::
	$(gradlew) classes

## builds jars, gradle assemble
build::
	$(gradlew) assemble

testArg := $(if $(tests),--tests *$(tests)*, )

test::
	$(gradlew) test integrationTest

## unit tests with gradle test, tests=PartialTestName will pass --tests *PartialTestName*
test.unit::
	$(gradlew) test $(testArg)

## integration and functional tests, tests=PartialTestName will pass --tests *PartialTestName*
test.e2e::
	$(gradlew) integrationTest $(testArg)

# verifies the snapshot is set
_verify-snapshot: FORCE
	_=$(if $(IS_SNAPSHOT),,$(error set snapshot=true in version properties))

## publish snapshot(s) jars into you local maven
publish.snapshot: | _verify-snapshot
	$(gradlew) snapshot

# here so we can depend on it being there and if not firing assemble
$(APP_JAR):
	$(gradlew) assemble

## java runs the APP_JAR
start.jar: $(APP_JAR)
	java -server -Xmx3048m -XX:MaxMetaspaceSize=256m -jar $(APP_JAR)

.PHONY: resolve-dependencies merge-test-results

# calls `gradlew resolveConfigurations` to download deps without compiling, used mostly for CI cache
gradle.resolve-dependencies:
	$(gradlew) resolveConfigurations --no-daemon

# on multi-project gradles this will merges test results into one spot for a CI build
gradle.merge-test-results: | _verify_PROJECT_SUBPROJECTS
	$(gradle_tools) merge_test_results "$(PROJECT_SUBPROJECTS)"
	$(logr.done)

# for multi-project gradles this cats the props and build.gradle into a single cache-key.tmp file
# for CI (such as circle) to checksum on a single file to see if there are any changes
# if any build files change then it will not get cache and gradle will re-download the internet
gradle.cache-key-file: | _verify_PROJECT_SUBPROJECTS
	cat $(gradle_properties) $(build_gradle) > cache-key.tmp
	for project in $(PROJECT_SUBPROJECTS); do
		[ -f $$project/build.gradle ] && cat $$project/build.gradle >> cache-key.tmp
		[ -f $$project/gradle.properties ] && cat $$project/gradle.properties >> cache-key.tmp
	done
	$(logr.done)

# legacy calls with no namespace
resolve-dependencies: gradle.resolve-dependencies

cache-key-file: gradle.cache-key-file

merge-test-results: gradle.merge-test-results

## publish the library jar, calls gradle publish
publish.libs:
	if [ "$(IS_SNAPSHOT)" ]; then $(logr) "publishing SNAPSHOT"; else $(logr) "publishing release"; fi
	if [ "$dry_run" ]; then
		echo "🌮 dry_run ->  $(gradlew) publish"
	else
		$(gradlew) publish
	fi

.PHONY: ship.libs publish.libs

ifdef RELEASABLE_BRANCH

# call for CI
ship.libs:: publish.libs
	$(logr.done)
else

ship.libs::
	$(logr.done) " - not a RELEASABLE_BRANCH, nothing to be done"

endif # end RELEASABLE_BRANCH
