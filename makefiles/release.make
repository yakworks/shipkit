# -------------
# targets for release process on git, not
# -------------

shipit := $(SHIPKIT_BIN)/ship_it

update-changelog: | _verify_VERSION _verify_PUBLISHED_VERSION _verify_RELEASE_CHANGELOG _verify_PROJECT_FULLNAME
	$(shipit) update_changelog $(VERSION) $(PUBLISHED_VERSION) $(RELEASE_CHANGELOG) $(PROJECT_FULLNAME)

update-readme-version: | _verify_VERSION
	$(shipit) replace_version "$(VERSION)" README.md

bump-version-props: | _verify_VERSION
	$(shipit) bump_version_props "$(VERSION)"

# updates change log, bumps version, updates the publishingVersion in README
push-version-bumps: update-changelog update-readme-version bump-version-props
	@echo "snapshot:false ... bumping versions"
	git add README.md version.properties "$(RELEASE_CHANGELOG)"
	git commit -m "v$(VERSION) changelog, version bump [ci skip]"
	git push -q $(GITHUB_URL) $(RELEASABLE_BRANCH)

# calls github endpoint to create a release on the RELEASABLE_BRANCH
create-github-release: | _verify_VERSION _verify_RELEASABLE_BRANCH _verify_PROJECT_FULLNAME _verify_GITHUB_TOKEN
	$(shipit) create_github_release $(VERSION) $(RELEASABLE_BRANCH) $(PROJECT_FULLNAME) $(GITHUB_TOKEN)

