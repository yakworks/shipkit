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
	@[ ! -e $(VAULT_DIR) ] && git clone $(VAULT_URL) $(VAULT_DIR) || :;
	cd build/vault && $(GIT_SECRET_SH) reveal -p "$(GPG_PASS)"

secrets.import-gpg-key: | _verify_BOT_EMAIL
	@if [ "$(GPG_PRIVATE_KEY)"  ]; then
		echo "importing GPG KEY"
		echo "$(GPG_PRIVATE_KEY)" | base64 --decode | gpg -v --batch --import
	fi
# gpg above --batch doesn't ask for prompt and -v is verbose

## run this to show help for secret goals
secrets.help:
	echo
	echo -e "${cbold}Git-secrets make tasks. see https://git-secret.io/ for more info on using installed version$(cnormal)\n"
	echo -e "Targets:\n"
	echo "$(ccyan)secrets.init                     $(cnormal)| initializes new project "
	echo "$(ccyan)secrets.add email=jim@gmail.com  $(cnormal)| adds an authorized user key, should only be by email that matched their public key "
	echo "$(ccyan)secrets.add file=secret.env      $(cnormal)| adds a file to the secrets"
	echo "$(ccyan)secrets.hide                     $(cnormal)| encrypts and hides all the files in the secret list "
	echo "$(ccyan)secrets.reveal                   $(cnormal)| decrytps all the files in the secret list "
	echo "$(ccyan)secrets.remove file=abc.env      $(cnormal)| removes a file to the secrets"
	echo "$(ccyan)secrets.remove email=...         $(cnormal)| removes an authroized user key"
	echo "$(ccyan)secrets.list                     $(cnormal)| list files and authorized users"
	echo "$(ccyan)secrets.clean                    $(cnormal)| removes all the hidden files"
	echo

# Shows the git-secret version
secrets.show-version: $(GIT_SECRET_SH)
	$(GIT_SECRET_SH) --version

# initializes the project
secrets.init: $(GIT_SECRET_SH)
	$(GIT_SECRET_SH) init

secrets.add:
	if [ "$(file)" ]; then
		$(GIT_SECRET_SH) add $(file)
	elif [ "$(email)" ]; then
		$(GIT_SECRET_SH) tell $(email)
	else
		echo "must set either the 'file' var or 'email' var"
	fi

secrets.remove:
	if [ "$(file)" ]; then
		$(GIT_SECRET_SH) remove $(file)
	elif [ "$(email)" ]; then
		$(GIT_SECRET_SH) removeperson $(email)
	else
		echo "must set either the 'file' var or 'email' var"
	fi

# alias to hide
secrets.encrypt: secrets.hide

secrets.hide: $(GIT_SECRET_SH)
	$(GIT_SECRET_SH) hide -d

# alias to reveal
secrets.decrypt: secrets.reveal

secrets.reveal:
	$(GIT_SECRET_SH) reveal -p "$(GPG_PASS)"

secrets.list:
	echo "$(cgreen) -- Secret Files --"
	$(GIT_SECRET_SH) list
	echo
	echo "$(cblue) -- Secret Users --"
	$(GIT_SECRET_SH) whoknows
