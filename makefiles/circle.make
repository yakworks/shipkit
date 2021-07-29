# -------------
# Common circle CI helpers.
# -------------

circle.sh := $(SHIPKIT_BIN)/circle

## Triggers circle to build project call with SLUG passed in, ex: make circle.trigger SLUG=yakworks/gorm-tools
circle.trigger: | _verify_CIRCLE_TOKEN _verify_SLUG
	$(circle.sh) trigger $(SLUG) $(CIRCLE_TOKEN)

SHELLCHECK_VERSION ?= v0.7.2
SHELLCHECK_TAR = shellcheck-$(SHELLCHECK_VERSION).linux.x86_64.tar.xz
SHELLCHECK_URL = https://github.com/koalaman/shellcheck/releases/download/$(SHELLCHECK_VERSION)/$(SHELLCHECK_TAR)

install-shellcheck-alpine:
	$(DOWNLOADER) $(DOWNLOAD_TO_FLAGS) shellcheck.tar.gz "$(SHELLCHECK_URL)"
	tar xvf shellcheck.tar.gz
	mv shellcheck-*/shellcheck /usr/bin/
	rm -rf shellcheck*
	ls -laF /usr/bin/shellcheck

# install the file command for alpine, file is used to get meta data on files to know if we should run in shellcheck
install-file-alpine:
	apk add file
