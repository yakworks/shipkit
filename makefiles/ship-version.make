# -------------
# targets for release process on git
# -------------

github.sh := $(SHIPKIT_BIN)/github
semver := $(SHIPKIT_BIN)/semver
changelog := $(SHIPKIT_BIN)/changelog

VERSION_FILENAME ?= version.properties
VERSION_SET_SNAPSHOT ?= false

update-changelog: | _verify_VERSION _verify_PUBLISHED_VERSION _verify_RELEASE_CHANGELOG _verify_PROJECT_FULLNAME
	$(changelog) update_changelog "$(VERSION)" "$(PUBLISHED_VERSION)" "$(RELEASE_CHANGELOG)" "$(PROJECT_FULLNAME)"
	echo $@ success

update-readme-version: | _verify_VERSION
	$(semver) replace_version "$(VERSION)" README.md
	echo $@ success

bump-version-file: | _verify_VERSION
	$(semver) bump_version_file "$(VERSION)" "$(VERSION_FILENAME)" "$(VERSION_SET_SNAPSHOT)"
	echo "$@ success on $(VERSION_FILENAME) for v:$(VERSION)"

# updates change log, bumps version, updates the publishingVersion in README
push-version-bumps:
	echo "snapshot:false ... bumping versions"
	git add README.md version.properties "$(RELEASE_CHANGELOG)"
	git commit -m "v$(VERSION) changelog, version bump [ci skip]"
	git push -q $(GITHUB_URL) $(RELEASABLE_BRANCH)
	echo $@ success


# -- release --
ifeq (true,$(IS_RELEASABLE))

# calls github endpoint to create a release on the RELEASABLE_BRANCH
ship.github-create: | _verify_VERSION _verify_RELEASABLE_BRANCH _verify_PROJECT_FULLNAME _verify_GITHUB_TOKEN
	$(github.sh) create_release  $(VERSION) $(RELEASABLE_BRANCH) $(PROJECT_FULLNAME) $(GITHUB_TOKEN)
	echo $@ success

## If IS_RELEASABLE, bump vesion, update changelong and post tagged release on gitub.
## Should almost always be last ship/release target
ship.version: update-changelog update-readme-version bump-version-file ship-github-create push-version-bumps
	echo $@ success

else # not IS_RELEASABLE, so its a snapshot or its not on a releasable branch

ship.version:
	echo "$@ IS_RELEASABLE=false as this is either a snapshot or its not on a releasable branch"

endif # end RELEASABLE_BRANCH
