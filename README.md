# Make rules them all

bash scripts and makefiles for a common way to build, test and deploy across projects 
no matter what the language.

## Why?
From https://github.blog/2015-06-30-scripts-to-rule-them-all/

> We have a lot of software running our products and company. We also have a lot of potential contributing members. Being able to get from git clone to an up-and-running project in a development environment is imperative for fast, reliable contributions. A consistent bootstrapping experience across all our projects reduces friction and encourages contribution.

With practically every software project, developers need to perform the following tasks:

- bootstrap
- run linter/code quality checks
- run tests
- run continuous integration
- start the app

We have normalized on a set of scripts and `Make` targets for all of our projects that individual contributors will be familiar with the second after they clone a project. 

We call this “Shipkit”.

## Assumptions about the build environment

The goal is to keep the dependencies light for base functionality and install whats needed on demand (such as for bats and git-secret). Whether your on your local dev machine or in a docker on a CI much of whats here assumes the following for a base shipkit environment.

- `bash` is available. 
- you have `Make` installed obviously. Its fairly ubiquitous and small but might need to install it
- `awk`, `grep` and `sed`, attempts are made to keep it compatible across gnu and mac os.
- `git`
- `ssh`
- `curl`

Depending on the project type, languages and what `makes` you include the following may also be needed
- `gnupg` for git-secret and encryption
- `java` - we use zulu from [Azul](https://www.azul.com/)
- `python`
- `node and npm`


## Good reads

Lost art of the makefile

- https://www.olioapps.com/blog/the-lost-art-of-the-makefile/
- https://3musketeers.io/

12 factor app is the philosophy

- https://12factor.net

## style guides we endeveur to follow

https://style-guides.readthedocs.io/en/latest/makefile.html
https://google.github.io/styleguide/shellguide.html


## Setup

best best is to take a look at https://github.com/yakworks/gorm-tools for a spring/grails example

WIP for a node and python links


# References

links for using make and docker
- https://amaysim.engineering/the-3-musketeers-how-make-docker-and-compose-enable-us-to-release-many-times-a-day-e92ca816ef17
- https://3musketeers.io/about/#what
- https://www.freecodecamp.org/news/want-to-know-the-easiest-way-to-save-time-use-make-eec453adf7fe/
- https://swcarpentry.github.io/make-novice/02-makefiles/
- https://krzysztofzuraw.com/blog/2016/makefiles-in-python-projects.html
- https://datakurre.pandala.org/2016/04/evolution-of-our-makefile-for-docker.html/
- https://engineering.docker.com/2019/06/containerizing-test-tooling-creating-your-dockerfile-and-makefile/
- https://github.com/marmelab/make-docker-command/blob/master/Makefile
- https://github.com/mvanholsteijn/docker-makefile
- https://itnext.io/docker-makefile-x-ops-sharing-infra-as-code-parts-ea6fa0d22946

## versioning example

- https://github.com/mvanholsteijn/docker-makefile

## docker makefiles
- https://philpep.org/blog/a-makefile-for-your-dockerfiles
- https://stackoverflow.com/questions/44969605/incrementally-build-docker-image-hierarchy-with-makefile
