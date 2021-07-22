# for downloading vault and running git-secret

GIT_SECRET_SH ?= $(SHIPKIT_INSTALLS)/git-secret/git-secret
GIT_SECRET_VERSION := 0.4.0
GIT_SECRET_URL     := https://github.com/sobolevn/git-secret/archive/refs/tags/v$(GIT_SECRET_VERSION).tar.gz
VAULT_DIR ?= $(BUILD_DIR)/vault

# on demand clone and install of git-secret
$(GIT_SECRET_SH):
	$(call download_tar,$(GIT_SECRET_URL),git-secret)
	cd $(SHIPKIT_INSTALLS)/git-secret && make build

vault-decrypt: import-gpg-key $(GIT_SECRET_SH) | _verify_VAULT_URL _verify_GPG_PASS
	@[ ! -e $(VAULT_DIR) ] && git clone $(VAULT_URL) $(VAULT_DIR) || :;
	cd build/vault && $(GIT_SECRET_SH) reveal -p "$(GPG_PASS)"

import-gpg-key: | _verify_GPG_PRIVATE_KEY _verify_BOT_EMAIL
	@if [ "$(GPG_PRIVATE_KEY)"  ]; then
		echo "importing GPG KEY"
		echo "$(GPG_PRIVATE_KEY)" | base64 --decode | gpg -v --batch --import
	fi
# gpg above --batch doesn't ask for prompt and -v is verbose

git-secret-version: $(GIT_SECRET_SH)
	$(GIT_SECRET_SH) --version

secrets-encrypt:
	@$(GIT_SECRET_SH) hide

secrets-decrypt:
	@$(GIT_SECRET_SH) reveal -p "$(GPG_PASS)"
