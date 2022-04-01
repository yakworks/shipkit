# -------------
# targets for release process on git, not
# -------------

GITHUB_BASE_URL ?= github.com/$(PROJECT_FULLNAME).git
GITHUB_URL ?= https://$(GITHUB_BASE_URL)

ifdef GITHUB_TOKEN
  GITHUB_URL = https://dummy:$(GITHUB_TOKEN)@$(GITHUB_BASE_URL)
endif

# $(info GITHUB_URL $(GITHUB_URL)) # logs out the bash echo from shResults

# clones the docs pages, normally to build/gh-pages for github
git.clone-pages: | _verify_PAGES_BRANCH _verify_PAGES_BUILD_DIR
	mkdir -p $(BUILD_DIR) && rm -rf "$(PAGES_BUILD_DIR)"
	git clone $(GITHUB_URL) $(PAGES_BUILD_DIR) -b $(PAGES_BRANCH) --single-branch --depth 1

# pushes the docs pages that was cloned into build, normally build/gh-pages for github
git.push-pages: | _verify_PAGES_BRANCH _verify_PROJECT_FULLNAME
	git -C $(PAGES_BUILD_DIR) add -A .
	git -C $(PAGES_BUILD_DIR) commit -a -m "CI Docs published [skip ci]" || true # or true so doesnt blow error if no changes
	git -C $(PAGES_BUILD_DIR) push -q $(GITHUB_URL) $(PAGES_BRANCH) || true


git.config-bot-user: export BOT_USER ?= $(shell echo $(BOT_EMAIL) | cut -d "@" -f1)
git.config-bot-user: git.config-signed-commits | _verify_BOT_EMAIL
	hasGitUser=`git config --global user.email || true`
	if [ ! "$$hasGitUser" ] || [ "$(CI)" ]; then
		git config credential.helper 'cache --timeout=120'
		git config --global user.name "$(BOT_USER)"
		git config --global user.email "$(BOT_EMAIL)"
		$(logr) "git.config-bot-user for $(BOT_USER)<$(BOT_EMAIL)>"
	fi

# assumes that the gpg.import-key has been run already and name matches.
# hack that looks for line from gpg like 'sec#  rsa4096/F8E8B580302AAEFA 2021-07-15 [SC] [expires: 2028-07-15]'
# and parses out the F8E8B580302AAEFA part. Then uses that to tell git what to use in case keys dont match
git.config-signed-commits:
	if [ "$$BOT_SIGN_COMMITS" = "true" ] ; then
		git config --global commit.gpgsign true
		secKeyId=$$(gpg --list-secret-keys --keyid-format=long | grep sec | cut -d'/' -f 2 | cut -d' ' -f 1)
		git config --global user.signingkey "$$secKeyId"
		$(logr) "signing commits with key id $$secKeyId"
	fi
