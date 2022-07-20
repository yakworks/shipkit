# -------------
# Common targets for docs engine
# -------------

docmark.sh := $(SHIPKIT_BIN)/docmark

DOCKMARK_SITE_DIR ?= $(BUILD_DIR)/site
GROOVYDOC_BUILD_DIR ?= $(BUILD_DIR)/docs/groovydoc

# --- Dockers ---

## show help list for docmark targets
help.docmark:
	$(MAKE) help HELP_REGEX="^docmark.*"

# serves the docmark docs from docker, alias to docker.dockmark-up
docmark.start: docker.dockmark-up

# serves the docmark docs from docker, alias to docker.dockmark-up
docmark.shell: docker.dockmark-shell

# docker for docmark docs, follow with a docker cmd  up, down, shell or pull
docker.dockmark: | _verify-DOCKER_CMD
	make docker.dockmark-$(DOCKER_CMD)

# start the docs server locally to serve pages
docker.dockmark-up:
	$(docmark.sh) docmark.run

# takes down the docker
docker.dockmark-down:
	$(docmark.sh) docker.remove docmark-serve

# use this to open shell and test targets for CI such as docmark-build
docker.dockmark-shell:
	$(docmark.sh) docmark.shell

# pulls the latest version
docker.dockmark-pull:
	docker pull "$(DOCMARK_DOCKER_IMAGE)"

# --- BUILDS ----

# copy readme to main index
docmark.copy-readme:
	$(docmark.sh) docmark.copy_readme $(VERSION)

# empty target that gets called before the build that main makefile can implement to do any special processing
docmark.build-prep:

# run inside docmark container, builds the docs. 'make docker-dockmark-shell' will start shell
docmark.build: docmark.build-prep
	docmark build --site-dir $(DOCKMARK_SITE_DIR)
