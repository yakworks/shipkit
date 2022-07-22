# Opinionated process to clone and decrypt a github project use as a "vault
# installs sops if not present on OS, will not be for build dockers, for local dev should already be there
# clones the github repo in VAULT_DIR, we call it the vault

SOP_VERSION := 3.7.1
SOP_URL     := https://github.com/mozilla/sops/releases/download/v$(SOP_VERSION)/sops-v$(SOP_VERSION).linux
VAULT_DIR   ?= $(BUILD_DIR)/vault
VAULT_FILES ?= bot.enc.env
VAULT_BOT_ENV_FILE := $(VAULT_DIR)/bot.env

VAULT_BASE_URL ?= github.com/$(VAULT_REPO).git
VAULT_GITHUB_URL ?= https://$(VAULT_BASE_URL)

ifdef GITHUB_TOKEN
  VAULT_GITHUB_URL = https://dummy:$(GITHUB_TOKEN)@$(VAULT_BASE_URL)
endif


# --- look for build/vault/bot.env , run  sops.decrypt-vault-files --
# we import it straight into make since these are secrets, dont want them in BUILD_VARS where they can get logged

ifneq ($(wildcard $(VAULT_BOT_ENV_FILE)),)
  include $(VAULT_BOT_ENV_FILE)
  # $ need to be escaped with another $ and # need to be escaped with a slash or it can think its comment
  cmd = sed '/^\#.*/d; /^$$/d; s/=.*//g;' $(VAULT_BOT_ENV_FILE)
  VAULT_ENV_VARS := $(shell $(cmd))
  # $(info including $(VAULT_ENV_VARS) from $(VAULT_ENV_FILE))
  export $(VAULT_ENV_VARS)
endif
# ---

SOP_SH := $(shell which sops 2> /dev/null)

# if doesn't already exists then above will be empty
ifeq ($(SOP_SH),)

 SOP_SH := $(SHIPKIT_INSTALLS)/sops
 # $(info sops is NOT installed)

endif

# on demand clone and install of git-secret for build dockers
# as a make reminder, if the file ref SOP_SH doesn't exist then this runs, if its there already then this does nothing
$(SOP_SH):
	$(logr) "intalling sops $(SOP_URL)"
	# make sure installs is created
	mkdir -p $(SHIPKIT_INSTALLS)
	curl -qsL $(SOP_URL) -o $(SOP_SH)
	chmod +x $(SOP_SH)
	$(logr.done)

## show help list for vault targets
help.vault:
	$(MAKE) help HELP_REGEX="^vault.+.*"

# installs sops, easier for testing
vault.sops.install: $(SOP_SH)

# clone vault from github
vault.clone: | _verify_VAULT_GITHUB_URL
	[ ! -e $(VAULT_DIR) ] && git clone $(VAULT_GITHUB_URL) $(VAULT_DIR) || :;

# alias for legacy refs
vault.decrypt: $(VAULT_DIR)

$(VAULT_DIR): | $(SOP_SH) vault.gpg.import-private-key vault.clone
	cd $(VAULT_DIR)
	for vfile in $(VAULT_FILES); do
		outFile="$${vfile/.enc./.}" # remove .enc.
		outFile="$${outFile/.encrypted./.}" # remove .encrypted.
		$(logr) "$$vfile > $$outFile"
		$(SOP_SH) -d $$vfile > $$outFile
	done
	$(logr.done)

# to test the gpg stuff set this to the base64 encoded key, DO NOT CHECK IN
# GPG_KEY=ZZZ
# set this to the gpg passphrase if needed, not base64
# GPG_PASS := xxx

# imports private key from GPG_PRIVATE_KEY var
vault.gpg.import-private-key:
	if [ "$(GPG_KEY)"  ]; then
		echo "$(GPG_KEY)" | base64 --decode | gpg -v --batch --import --quiet --no-verbose
		$(logr) "GPG_KEY imported"
	else
		$(logr.warn) "GPG_KEY not set, no key was imported"
	fi

# encrypts a dummy file so that it doesnt ask again for passphrase when sops is run
# this is only needed if using a private key that has passphrase,
# kept here for reference but not used right now
gpg.passphrase:
	if [ "$(GPG_PASS)" ]; then
		touch build/dummy.txt
		# a bit remarkable that this is what it takes but it is.
		echo $(GPG_PASS) | gpg -q --sign --batch --pinentry-mode loopback --passphrase-fd 0 --output /dev/null --yes build/dummy.txt
	fi

# gpg above --batch doesn't ask for prompt and -v is verbose

clean.vault:
	rm -rf $(VAULT_DIR)
