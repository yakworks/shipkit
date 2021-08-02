# for downloading vault and running git-secret

GIT_SECRET_SH ?= $(SHIPKIT_INSTALLS)/git-secret/git-secret
GIT_SECRET_VERSION := 0.4.0
GIT_SECRET_URL     := https://github.com/sobolevn/git-secret/archive/refs/tags/v$(GIT_SECRET_VERSION).tar.gz
VAULT_DIR ?= $(BUILD_DIR)/vault

# on demand clone and install of git-secret
$(GIT_SECRET_SH):
	$(call download_tar,$(GIT_SECRET_URL),git-secret)
	cd $(SHIPKIT_INSTALLS)/git-secret && make build

secrets.decrypt-vault: secrets.import-gpg-key $(GIT_SECRET_SH) | _verify_VAULT_URL _verify_GPG_PASS
	[ ! -e $(VAULT_DIR) ] && git clone $(VAULT_URL) $(VAULT_DIR) || :;
	cd build/vault && $(GIT_SECRET_SH) reveal -p "$(GPG_PASS)"
	$(_finished)

secrets.import-gpg-key: | _verify_BOT_EMAIL
	@if [ "$(GPG_PRIVATE_KEY)"  ]; then
		$(logr) "importing GPG KEY"
		echo "$(GPG_PRIVATE_KEY)" | base64 --decode | gpg -v --batch --import
	fi
# gpg above --batch doesn't ask for prompt and -v is verbose

## run this to show help for secret goals
secrets.help:
	printf "\n$(cmagenta)Git-secrets make tasks. see https://git-secret.io/ for more info on using installed version$(creset)\n\n"
	printf "$(culine)Targets:\n\n$(creset)"
	printf "$(ccyanB)secrets.init                     $(creset)| initializes new project \n"
	printf "$(ccyanB)secrets.add email=jim@gmail.com  $(creset)| adds an authorized user key, should only be by email that matched their public key \n"
	printf "$(ccyanB)secrets.add file=secret.env      $(creset)| adds a file to the secrets \n"
	printf "$(ccyanB)secrets.hide                     $(creset)| encrypts and hides all the files in the secret list \n"
	printf "$(ccyanB)secrets.reveal                   $(creset)| decrytps all the files in the secret list \n"
	printf "$(ccyanB)secrets.remove file=abc.env      $(creset)| removes a file to the secrets \n"
	printf "$(ccyanB)secrets.remove email=...         $(creset)| removes an authroized user key \n"
	printf "$(ccyanB)secrets.list                     $(creset)| list files and authorized users \n"
	printf "$(ccyanB)secrets.clean                    $(creset)| removes all the hidden files \n"
	printf "\n"
	printf "$(cbold)If using a git repo as a vault linked the VAULT_URL variable then\n"
	printf "$(ccyanB)secrets.decrypt-vault   $(creset)| clone in VAULT_DIR and decrypt/reveal. bot.env here is used in other shipkit scripts\n\n"

# Shows the git-secret version
secrets.show-version: $(GIT_SECRET_SH)
	$(GIT_SECRET_SH) --version

# initializes the project
secrets.init: $(GIT_SECRET_SH)
	$(GIT_SECRET_SH) init

secrets.add: $(GIT_SECRET_SH)
	if [ "$(file)" ]; then
		$(GIT_SECRET_SH) add $(file)
	elif [ "$(email)" ]; then
		$(GIT_SECRET_SH) tell $(email)
	else
		$(logr.error) "must set either the 'file' var or 'email' var"
	fi

secrets.remove: $(GIT_SECRET_SH)
	if [ "$(file)" ]; then
		$(GIT_SECRET_SH) remove $(file)
	elif [ "$(email)" ]; then
		$(GIT_SECRET_SH) killperson $(email)
	else
		$(logr.error) "must set either the 'file' var or 'email' var"
	fi

# alias to hide
secrets.encrypt: secrets.hide

secrets.hide: $(GIT_SECRET_SH)
	$(GIT_SECRET_SH) hide -d

# alias to reveal
secrets.decrypt: secrets.reveal

secrets.reveal: $(GIT_SECRET_SH)
	$(GIT_SECRET_SH) reveal -p "$(GPG_PASS)"

secrets.list: $(GIT_SECRET_SH)
	printf "$(cgreen) -- Secret Files --\n"
	$(GIT_SECRET_SH) list
	echo
	printf "$(cblue) -- Secret Users --\n"
	$(GIT_SECRET_SH) whoknows
