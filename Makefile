# ---------------------------------------------------------------------------- #
#             Apache 2.0 License Copyright © 2022 The Aurae Authors            #
#                                                                              #
#                +--------------------------------------------+                #
#                |   █████╗ ██╗   ██╗██████╗  █████╗ ███████╗ |                #
#                |  ██╔══██╗██║   ██║██╔══██╗██╔══██╗██╔════╝ |                #
#                |  ███████║██║   ██║██████╔╝███████║█████╗   |                #
#                |  ██╔══██║██║   ██║██╔══██╗██╔══██║██╔══╝   |                #
#                |  ██║  ██║╚██████╔╝██║  ██║██║  ██║███████╗ |                #
#                |  ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ |                #
#                +--------------------------------------------+                #
#                                                                              #
#                         Distributed Systems Runtime                          #
#                                                                              #
# ---------------------------------------------------------------------------- #
#                                                                              #
#   Licensed under the Apache License, Version 2.0 (the "License");            #
#   you may not use this file except in compliance with the License.           #
#   You may obtain a copy of the License at                                    #
#                                                                              #
#       http://www.apache.org/licenses/LICENSE-2.0                             #
#                                                                              #
#   Unless required by applicable law or agreed to in writing, software        #
#   distributed under the License is distributed on an "AS IS" BASIS,          #
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
#   See the License for the specific language governing permissions and        #
#   limitations under the License.                                             #
#                                                                              #
# ---------------------------------------------------------------------------- #


branch       ?=  main
message      ?=  Default commit message. Aurae Runtime environment.
cargo         =  cargo

default: compile install
all: compile install

compile: aurae auraed ## Compile for the local architecture ⚙

install: ## Build and install (debug) 🎉
	@$(cargo) install --path ./aurae --debug
	@$(cargo) install --path ./auraed --debug

release: ## Build and install (release) 🎉
	@$(cargo) install --path ./aurae
	@$(cargo) install --path ./auraed

.PHONY: aurae
aurae: ## Initialize and compile aurae
	@if [ ! -d aurae ]; then printf "\n\nError: Missing submodules. Run 'make submodule' to download aurae source before compiling.\n\n"; exit 1; fi
	@$(cargo) clippy -p aurae
	@$(cargo) install --path ./aurae --debug

.PHONY: auraed
auraed: ## Initialize and compile auraed
	@if [ ! -d auraed ]; then printf "\n\nError:\nun 'make submodule' to download auraed source before compiling.\n\n"; exit 1; fi
	@$(cargo) clippy -p auraed
	@$(cargo) install --path ./auraed --debug

test: ## Run the tests
	@$(cargo) test

export GIT_PAGER = cat

push: ## (git) Push branch="NAME"
	cd aurae && git push origin $(branch)
	cd auraed && git push origin $(branch)
	cd api && git push origin $(branch)
	cd scripts && git push origin $(branch)
	git push origin $(branch)

add: ## (git) Add . (dangerous)
	cd aurae && git add .
	cd auraed && git add .
	cd api && git add .
	cd scripts && git add .
	git add .

commit: ## (git) Commit message="MESSAGE"
	cd aurae && git commit -s -m "$(message)" || true
	#cd auraectl && git commit -s -m "$(message)" || true
	cd auraed && git commit -s -m "$(message)" || true
	#cd authx && git commit -s -m "$(message)" || true
	cd api && git commit -s -m "$(message)" || true
	cd scripts && git commit -s -m "$(message)" || true
	git add .
	git commit -s -m "$(message)" || true

checkout: ## (git) Checkout branch="NAME"
	git checkout $(branch) || git checkout -b $(branch)
	cd aurae && git checkout $(branch) || git checkout -b $(branch)
	cd auraed && git checkout $(branch) || git checkout -b $(branch)
	cd api && git checkout $(branch) || git checkout -b $(branch)
	cd scripts && git checkout $(branch) || git checkout -b $(branch)

status: ## (git) Status
	git status
	cd aurae && git status
	cd auraed && git status
	cd api && git status
	cd scripts && git status

pull: ## (git) Pull branch="NAME"
	git pull origin $(branch)
	cd aurae && git pull origin $(branch)
	cd auraed && git pull origin $(branch)
	cd api && git pull origin $(branch)
	cd scripts && git pull origin $(branch)

submodules: submodule ## Alias for submodule
submodule: ## Initialize all submodules
	@echo "Initializing submodules"
	@echo ""
	@read -p "Warning: This will destroy all work in subdirectories! Press any key to continue." FOO

	# Aurae
	@if [ -d /tmp/aurae ]; then rm -rvf /tmp/aurae; fi
	@if [ -d aurae ]; then mv -v aurae /tmp/aurae; fi

	# Auraectl
	#@if [ -d /tmp/auraectl ]; then rm -rvf /tmp/auraectl; fi
	#@if [ -d auraectl ]; then mv -v auraectl /tmp/auraectl; fi

	# Auraed
	@if [ -d /tmp/auraed ]; then rm -rvf /tmp/auraed; fi
	@if [ -d auraed ]; then mv -v auraed /tmp/auraed; fi

	# API
	@if [ -d /tmp/api ]; then rm -rvf /tmp/api; fi
	@if [ -d api ]; then mv -v api /tmp/api; fi

	# Scripts
	@if [ -d /tmp/scripts ]; then rm -rvf /tmp/scripts; fi
	@if [ -d scripts ]; then mv -v scripts /tmp/scripts; fi

	# Init and update
	@git submodule update --init --recursive
	@git submodule update --remote --rebase

	# Attach to main
	cd aurae && git checkout $(branch) && git branch && git pull origin $(branch)
	#cd auraectl && git checkout $(branch) && git branch && git pull origin $(branch)
	cd auraed && git checkout $(branch) && git branch && git pull origin $(branch)
	#cd authx && git checkout $(branch) && git branch && git pull origin $(branch)
	cd api && git checkout $(branch) && git branch && git pull origin $(branch)
	cd scripts && git checkout $(branch) && git branch && git pull origin $(branch)

.PHONY: config
config: ## Set up default config
	@mkdir -p $(HOME)/.aurae
	@cp -v aurae/default.config.toml $(HOME)/.aurae/config
	@sed -i 's|~|$(HOME)|g' $(HOME)/.aurae/config
	@mkdir -p $(HOME)/.aurae/pki
	@cp -v pki/* $(HOME)/.aurae/pki

tlsinfo: ## Show TLS Info for /var/run/aurae*
	./hack/server-tls-info

.PHONY: pki
pki: certs ## Alias for certs
certs: clean-certs ## Generate x509 mTLS certs in /pki directory
	./hack/certgen
	sudo -E mkdir -p /etc/aurae/pki
	sudo -E cp -v pki/* /etc/aurae/pki
	@echo "Install PKI Auth Material [/etc/aurae]"


clean-certs: ## Clean the cert material
	@rm -rvf pki/*

fmt: headers ## Format the entire code base(s)
	@./hack/code-format

.PHONY: clean
clean: clean-certs
	cd aurae && make clean
	#cd auraectl && make clean
	cd auraed && make clean
	@rm -rvf target/*

headers: headers-write ## Fix headers. Run this if you want to clobber things.

headers-check: ## Only check for problematic files.
	./hack/headers-check

headers-write: ## Fix any problematic files blindly.
	./hack/headers-write

.PHONY: help
help:  ## Show help messages for make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'
