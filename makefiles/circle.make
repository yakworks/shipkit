# -------------
# Common circle CI helpers.
# -------------

circle.sh := $(SHIPKIT_BIN)/circle

## Triggers circle to build project call. Will use PROJECT_FULLNAME and defaults to current branch.
## pass `b=some_branch` to specify a different one.
circle.trigger: | _verify_CIRCLE_TOKEN _verify_PROJECT_FULLNAME
	$(circle.sh) trigger $(b)


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
