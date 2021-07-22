# -------------
# Common circle CI helpers.
# -------------

circle.sh := $(SHIPKIT_BIN)/circle

## Triggers circle to build project call with SLUG passed in, ex: make trigger-circle SLUG=yakworks/gorm-tools
trigger-circle: | _verify_CIRCLE_TOKEN _verify_SLUG
	curl --location --request POST \
		"https://circleci.com/api/v2/project/github/$(SLUG)/pipeline" \
		--header 'Content-Type: application/json' \
		-u "$(CIRCLE_TOKEN):"

SHELLCHECK_VERSION ?= v0.7.2
SHELLCHECK_TAR = shellcheck-$(SHELLCHECK_VERSION).linux.x86_64.tar.xz
SHELLCHECK_URL = https://github.com/koalaman/shellcheck/releases/download/$(SHELLCHECK_VERSION)/$(SHELLCHECK_TAR)

install-shellcheck-alpine:
	$(DOWNLOADER) $(DOWNLOAD_TO_FLAGS) shellcheck.tar.gz "$(SHELLCHECK_URL)"
	tar xvf shellcheck.tar.gz
	mv shellcheck-*/shellcheck /usr/bin/
	rm -rf shellcheck*
	ls -laF /usr/bin/shellcheck
