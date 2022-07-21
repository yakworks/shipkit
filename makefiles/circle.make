# -------------
# Common circle CI helpers.
# -------------

circle.sh := $(SHIPKIT_BIN)/circle

## show help list for circle targets
help.circle:
	$(MAKE) help HELP_REGEX="^circle.*"

# Triggers circle to build project call. Will use PROJECT_FULLNAME and defaults to current branch.
# pass `b=some_branch` to specify a different one.
circle.trigger: | _verify_CIRCLE_TOKEN _verify_PROJECT_FULLNAME
	$(circle.sh) trigger $(b)


# opens the circle pipeline for this project in the default web browser. only works on mac right now.
circle.open: | _verify_CIRCLE_TOKEN _verify_PROJECT_FULLNAME
	$(circle.sh) open

# creates a file with todays date and version.properties to use circles checksum to create a daily cachekey file
circle.day-version-cache-key-file: | _verify_PROJECT_SUBPROJECTS
	cat version.properties > day-version-cache-key.tmp
	date +%F  >> day-version-cache-key.tmp
	$(logr.done)

SHELLCHECK_VERSION ?= v0.7.2
SHELLCHECK_TAR = shellcheck-$(SHELLCHECK_VERSION).linux.x86_64.tar.xz
SHELLCHECK_URL = https://github.com/koalaman/shellcheck/releases/download/$(SHELLCHECK_VERSION)/$(SHELLCHECK_TAR)

install-shellcheck-alpine:
	$(DOWNLOADER) $(DOWNLOAD_TO_FLAGS) shellcheck.tar.gz "$(SHELLCHECK_URL)"
	tar xvf shellcheck.tar.gz
	mv shellcheck-*/shellcheck /usr/bin/
	rm -rf shellcheck*
	ls -laF /usr/bin/shellcheck

install-shellcheck-debian:
	apt-get -qq -y --no-install-recommends install shellcheck

# install the file command for alpine, file is used to get meta data on files to know if we should run in shellcheck
install-file-alpine:
	apk add file

install-file-debian:
	apt-get -qq -y --no-install-recommends install file

debian.install-circle-deps: install-file-debian install-shellcheck-debian
