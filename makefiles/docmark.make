# -------------
# Common targets for docs engine
# -------------

docmark.sh := $(SHIPKIT_BIN)/docmark

DOCKMARK_SITE_DIR ?= $(BUILD_DIR)/site
GROOVYDOC_BUILD_DIR ?= $(BUILD_DIR)/docs/groovydoc

# --- Dockers ---
## docker for docmark docs, follow with a docker cmd  up, down, shell or pull
docker-dockmark: | _verify-DOCKER_CMD
	make docker-dockmark-$(DOCKER_CMD)

# start the docs server locally to serve pages
docker-dockmark-up:
	@$(docmark.sh) docmark_run

# takes down the docker
docker-dockmark-down:
	@$(docmark.sh) dockerRemove docmark-serve

# use this to open shell and test targets for CI such as docmark-build
docker-dockmark-shell:
	@$(docmark.sh) docmark_shell

# pulls the latest version
docker-dockmark-pull:
	@$(docmark.sh) docmark_pull

# --- BUILDS ----

# copy readme to main index
docmark-copy-readme:
	@$(docmark.sh) cp_readme_index $(VERSION)

# empty target that gets called before the build that main makefile can implement to do any special processing
docmark-build-prep:

## run inside docmark container, builds the docs. 'make docker-dockmark-shell' will start shell
docmark-build: docmark-build-prep
	docmark build --site-dir $(DOCKMARK_SITE_DIR)
