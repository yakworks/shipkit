# -------------
# Common circle CI helpers.
# -------------

circle.sh := $(SHIPKIT_BIN)/circle

# generates the cache-key.tmp for CI to checksum. depends on PROJECT_SUBPROJECTS var
cache-key-file: | _verify_PROJECT_SUBPROJECTS
	@$(circle.sh) create_cache_key "$(PROJECT_SUBPROJECTS)"

# call with SLUG passed in, ex: make trigger-circle SLUG=yakworks/gorm-tools
trigger-circle: | _verify_CIRCLE_TOKEN _verify_SLUG
	curl --location --request POST \
		"https://circleci.com/api/v2/project/github/$(SLUG)/pipeline" \
		--header 'Content-Type: application/json' \
		-u "$(CIRCLE_TOKEN):"
