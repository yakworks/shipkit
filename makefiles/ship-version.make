# -------------
# targets for release process on git
# -------------

github.sh := $(SHIPKIT_BIN)/github
semver := $(SHIPKIT_BIN)/semver
changelog := $(SHIPKIT_BIN)/changelog

VERSION_FILENAME ?= version.properties
# VERSION_SET_SNAPSHOT ?= false
# RELEASE_RESET_FLAG ?= false

update-changelog: | _verify_VERSION _verify_PUBLISHED_VERSION _verify_RELEASE_CHANGELOG _verify_PROJECT_FULLNAME
	$(changelog) update_changelog "$(VERSION)" "$(PUBLISHED_VERSION)" "$(RELEASE_CHANGELOG)" "$(PROJECT_FULLNAME)"
	$(logr.done)

update-readme-version: | _verify_VERSION
	$(semver) replace_version "$(VERSION)" README.md
	$(logr.done)

bump-version-file: | _verify_VERSION
	$(semver) bump_version_file "$(VERSION)" "$(VERSION_FILENAME)"
	$(logr.done) " with $(VERSION_FILENAME) for v:$(VERSION)"

# updates change log, bumps version, updates the publishingVersion in README
push-version-bumps:
	$(logr) "snapshot:false ... bumping versions"
	if [ "$(dry_run)" ]; then
		echo "🌮 dry_run ->  push-version-bumps"
	else
		git add README.md version.properties "$(RELEASE_CHANGELOG)"
		git commit -m "v$(VERSION) changelog, version bump [ci skip]"
		# incase needed uses --force
		git push $(GITHUB_URL) $(PUBLISHABLE_BRANCH)
		$(logr.done)
	fi

# -- release --
ifneq ($(or $(IS_RELEASABLE),$(dry_run)),)

 # calls github endpoint to create a release on the PUBLISHABLE_BRANCH
 ship.github-release: | _verify_VERSION _verify_PROJECT_FULLNAME _verify_GITHUB_TOKEN
	$(github.sh) create_release  $(PUBLISHED_VERSION) $(PUBLISHABLE_BRANCH) $(PROJECT_FULLNAME) $(GITHUB_TOKEN)
	$(logr.done)

 ## If IS_RELEASABLE, bump vesion, update changelong and post tagged release on gitub.
 ## Should almost always be last ship/release target
 ship.version: update-changelog update-readme-version bump-version-file push-version-bumps
	# do the ship.github-release in new make so it reloads and picks up the changed PUBLISHED_VERSION
	$(MAKE) ship.github-release
	$(logr.done)

else # not IS_RELEASABLE, so its a snapshot or its not on a releasable branch

 ship.version:
	$(logr.done) " - IS_RELEASABLE=false as this is either a snapshot or its not on a releasable branch"

endif # end PUBLISHABLE_BRANCH

# changes verison.properties to snapshot=false and force pushes commit with release message to git.
# push-snapshot-false:
# 	sed -i.bak -e "s/^snapshot=.*/snapshot=false/g" version.properties && rm version.properties.bak
# 	git add version.properties
# 	git commit -m "trigger release"
# 	git push
# 	$(logr.done)
