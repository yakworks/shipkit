
# clones pages branch, builds and copies into branch, doesn't push,
# git_push_pages should be called after this or task that calls the push should depend on this one
# this should be run inside of the docmark docker
docmark.publish-prep: docmark.build git.clone-pages
	cp -r $(DOCKMARK_SITE_DIR)/. $(PAGES_BUILD_DIR)
	if [ -d "$(GROOVYDOC_BUILD_DIR)" ]; then
		cp -r $(GROOVYDOC_BUILD_DIR) $(PAGES_BUILD_DIR)/groovydocs
	fi

## Builds and pushes docmark pages to github pages, CI should call publish-docs which calls this
pages.deploy-github: docmark.publish-prep
	if [ "$(dry_run)" ]; then
		echo "🌮 dry_run ->  $(MAKE) git.push-pages"
	else
		$(MAKE) git.push-pages
	fi
	$(logr.done)

# TODO at some point we want to look at publishing snapshot version of docs like we once did?
# NOT_SNAPSHOT := $(if $(IS_SNAPSHOT),,true)
# ifneq (,$(and $(RELEASABLE_BRANCH),$(NOT_SNAPSHOT)))

.PHONY: ship.gh-pages

ifneq ($(or $(IS_RELEASABLE),$(dry_run)),)

 ship.gh-pages:
	$(MAKE) pages.deploy-github
	$(logr.done)
else

 ship.gh-pages:
	$(logr.done) " - IS_RELEASABLE=false as this is either a snapshot or its not on a releasable branch"

endif
