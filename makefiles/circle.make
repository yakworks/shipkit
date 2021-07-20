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
