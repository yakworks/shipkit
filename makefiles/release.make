# -------------
# targets for release process on git
# -------------

github_release := $(SHIPKIT_BIN)/github_release
semver := $(SHIPKIT_BIN)/semver
changelog := $(SHIPKIT_BIN)/changelog

update-changelog: | _verify_VERSION _verify_PUBLISHED_VERSION _verify_RELEASE_CHANGELOG _verify_PROJECT_FULLNAME
	$(changelog) update_changelog $(VERSION) $(PUBLISHED_VERSION) $(RELEASE_CHANGELOG) $(PROJECT_FULLNAME)

update-readme-version: | _verify_VERSION
	$(semver) replace_version "$(VERSION)" README.md

bump-version-props: | _verify_VERSION
	$(semver) bump_version_file "$(VERSION)" version.properties

# updates change log, bumps version, updates the publishingVersion in README
push-version-bumps:
	@echo "snapshot:false ... bumping versions"
	git add README.md version.properties "$(RELEASE_CHANGELOG)"
	git commit -m "v$(VERSION) changelog, version bump [ci skip]"
	git push -q $(GITHUB_URL) $(RELEASABLE_BRANCH)


# these are empty so they are always there for CI to call, will do nothing if not IS_RELEASABLE
semantic-release:

create-github-release:

# -- release --
ifeq (true,$(IS_RELEASABLE))

  # calls github endpoint to create a release on the RELEASABLE_BRANCH
  create-github-release: | _verify_VERSION _verify_RELEASABLE_BRANCH _verify_PROJECT_FULLNAME _verify_GITHUB_TOKEN
	$(github_release) create_github_release $(VERSION) $(RELEASABLE_BRANCH) $(PROJECT_FULLNAME) $(GITHUB_TOKEN)

  semantic-release: update-changelog update-readme-version bump-version-props
	echo "Releasable ... doing version bump, changelog and tag push"
	make create-github-release
	make push-version-bumps

endif # end RELEASABLE_BRANCH
