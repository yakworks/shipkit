# -------------
# targets for release process on git, not
# -------------

GITHUB_BASE_URL ?= github.com/$(PROJECT_FULLNAME).git
GITHUB_URL ?= https://$(GITHUB_BASE_URL)

ifdef GITHUB_TOKEN
  GITHUB_URL = https://dummy:$(GITHUB_TOKEN)@$(GITHUB_BASE_URL)
endif # end RELEASABLE_BRANCH

# $(info GITHUB_URL $(GITHUB_URL)) # logs out the bash echo from shResults

# clones the docs pages, normally to build/gh-pages for github
git-clone-pages: | _verify_PAGES_BRANCH _verify_PAGES_BUILD_DIR
	@mkdir -p $(BUILD_DIR) && rm -rf "$(PAGES_BUILD_DIR)"
	git clone $(GITHUB_URL) $(PAGES_BUILD_DIR) -b $(PAGES_BRANCH) --single-branch --depth 1

# pushes the docs pages that was cloned into build, normally build/gh-pages for github
git-push-pages: | _verify_PAGES_BRANCH _verify_PROJECT_FULLNAME
	@git -C $(PAGES_BUILD_DIR) add -A .
	@git -C $(PAGES_BUILD_DIR) commit -a -m "CI Docs published [skip ci]" || true # or true so doesnt blow error if no changes
	@git -C $(PAGES_BUILD_DIR) push -q $(GITHUB_URL) $(PAGES_BRANCH) || true


config-bot-git-user: BOT_USER ?= $(shell echo $(BOT_EMAIL) | cut -d "@" -f1)
config-bot-git-user: | _verify_BOT_EMAIL
	hasGitUser=`git config --global user.email || true`
	if [ ! "$$hasGitUser" ] || [ "$(CI)" ]; then
		echo "config-bot-git-user for $(BOT_USER)<$(BOT_EMAIL)>"
		git config credential.helper 'cache --timeout=120'
		git config --global user.name "$(BOT_USER)"
		git config --global user.email "$(BOT_EMAIL)"
	fi
