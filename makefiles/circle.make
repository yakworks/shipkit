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

SHELLCHECK_VERSION ?= 0.7.2
SHELLCHECK_TAR = shellcheck-$(SHELLCHECK_VERSION).linux.x86_64.tar.xz

alpine-install-shellcheck:
	tar=shellcheck-$(SHELLCHECK_VERSION).linux.x86_64.tar.xz
	curl -sSL https://github.com/koalaman/shellcheck/releases/download/$(SHELLCHECK_VERSION)/$(SHELLCHECK_TAR) -o shellcheck.tar.gz
	mkdir -p /usr/src/shellcheck
	tar xvf shellcheck.tar.gz
	mv shellcheck-*/shellcheck /usr/bin/
	rm -rf shellcheck*
