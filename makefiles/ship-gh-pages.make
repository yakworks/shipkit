
# clones pages branch, builds and copies into branch, doesn't push,
# git_push_pages should be called after this or task that calls the push should depend on this one
# this should be run inside of the docmark docker
docmark-publish-prep: docmark-build git-clone-pages
	@cp -r $(DOCKMARK_SITE_DIR)/. $(PAGES_BUILD_DIR)
	if [ -d "$(GROOVYDOC_BUILD_DIR)" ]; then
		cp -r $(GROOVYDOC_BUILD_DIR) $(PAGES_BUILD_DIR)/groovydocs
	fi

## Builds and pushes docmark pages to github pages, CI should call publish-docs which calls this
gh-pages-deploy: docmark-publish-prep
	$(MAKE) git-push-pages
	echo "$@ success"


.PHONY: ship-gh-pages
# CI to call this to relase/publish docs. only does work if IS_RELEASABLE
ship-gh-pages:

# TODO at some point we want to look at publishing snapshot version of docs like we once did?
# NOT_SNAPSHOT := $(if $(IS_SNAPSHOT),,true)
# ifneq (,$(and $(RELEASABLE_BRANCH),$(NOT_SNAPSHOT)))

ifeq (true,$(IS_RELEASABLE))

 ship-gh-pages:
	$(MAKE) gh-pages-deploy

endif
