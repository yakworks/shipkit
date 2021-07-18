# This is kind of like an interface or contract
# not matter what language the project is, these are the standard target names to use

# -- standard names, all double :: so you can have many
# NOTE: any targets implemneted in main Makefile or others must also have :: for these
# See https://www.gnu.org/software/make/manual/make.html#Double_002dColon for more information.

## removes build artifacts
clean::
	@:

## runs lint and code style checks
lint::
	@:

## compiles the app
compile::
	@:

## Run the lint and tests
check::
	@:

## runs all tests
test::
	@:

## runs unit tests
test-unit::
	@:

## runs integration/e2e tests
test-e2e::
	@:

## builds the libs
build::
	@:

## publish the libs
publish::
	@:

# Full release, version bump, changelog update... usually only CI
release::
	@:

# Deploy the app. dockerize, kubernetes, etc... usually only CI will run this
deploy::
	@:

.PHONY: clean lint compile check test test-unit test-e2e build publish release deploy

