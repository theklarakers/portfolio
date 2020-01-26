# File in which we expect the Ansible Vault password
CRYPT_SECRET ?= .ansible-vault-password

# Ansible Vault command shortcut
ANSIBLE_VAULT_ARGS = --vault-id $(CRYPT_SECRET)
ANSIBLE_VAULT = ansible-vault $(ANSIBLE_ACTION)

# This will decrypt any .env targets automatically (requires there is a .env.enc available).
%/.env: %/.env.enc | $(CRYPT_SECRET)
	$(__DECRYPT)

## .ansible-vault-password: Creates the Ansible Vault secret file
$(CRYPT_SECRET):
	@exec < /dev/tty && \
	echo -n "Please input Ansible Vault password: " && \
	read -s response && \
	echo $$response > $@ && \
	exec <&-

SECRETHUB_ARGS ?=
# Shortcuts for invoking the secrethub binaries
SECRETHUB_DOCKER_ARGS ?=
SECRETHUB = docker run \
	-v $HOME/.secrethub:/root/.secrethub \
	-v $(ROOT_DIR):/workspace \
	--workdir /workspace \
	$(KUBECTL_DOCKER_ARGS) \
	secrethub/cli \
	$(KUBECTL_ARGS)

# Helpers

__DECRYPT = \
	$(info Decrypting $< to $@) \
	$(ANSIBLE_VAULT) decrypt $(ANSIBLE_VAULT_ARGS) --output $@ $<

__CRYPT = \
	$(info Encrypting $< to $@) \
	$(ANSIBLE_VAULT) encrypt $(ANSIBLE_VAULT_ARGS) --output $@ $<

.PHONY: entrypoint-ansible-vault
entrypoint-ansible-vault: $(CRYPT_SECRET)
	$(ANSIBLE_VAULT) $(ANSIBLE_VAULT_ARGS) $(ARGS)