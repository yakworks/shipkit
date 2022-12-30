[![CircleCI](https://img.shields.io/circleci/project/github/yakworks/shipkit/master.svg?longCache=true&style=for-the-badge&logo=circleci)](https://circleci.com/gh/yakworks/shipkit)
![GitHub](https://img.shields.io/github/license/yakworks/shipkit?style=for-the-badge)
<img src="docs/ship-kit.svg" height="28">
[![9ci](https://img.shields.io/badge/BUILT%20BY-9ci%20Inc-blue.svg?longCache=true&style=for-the-badge)](http://9ci.com)
<img src="https://forthebadge.com/images/badges/gluten-free.svg" height="28">

# BAM (Bash & Make) CI/CD Tool

<img src="docs/bam-bash-make.svg" height="28">

- scripts and makefiles based CI/CD tool. 
- ship every change to production without hassle. 
- Automated versioning, generating release notes
- Documentation builder
- Automated publishing

For a standardized way to build, test and deploy across projects that stays out of your way, no matter what the language.

## TOC 

<!-- TOC depthfrom:undefined depthto:undefined orderedlist:undefined -->



<!-- /TOC -->

<!-- THIS table of contents above  IS a VS CODE PLUGIN here https://github.com/huntertran/markdown-toc, make sure thats what your using.   -->

## Bash Scripts Usage Docs

  [See Here For Shipkits Bash Scripts](docs/USAGE.md)

## Why BAM (Bash & Make)?

> We have a lot of software running our products and company. We also have a lot of potential contributing members. 
> Being able to get from git clone to an up-and-running project in a development environment is imperative for fast, 
> reliable contributions. A consistent bootstrapping experience across all our projects reduces 
> friction and encourages contribution. --[source](https://github.blog/2015-06-30-scripts-to-rule-them-all/)

With practically every software project, developers need to perform the following tasks:

- bootstrap
- run linter/code quality checks
- run tests
- run continuous integration
- start the app

We have normalized on a set of `Bash` scripts and `Make` targets for all of our projects that individual contributors will be familiar with the second after they clone a project. 

### Bash?

Yes we need it. Its basically every where. And when using an alpine docker image, Bash only adds about 800k compressed, and 2.2 mb uncompressed. So its what we require on our docker images to run this. 

### Make?

> Make is a general-purpose build tool that has been improved upon and refined continuously since its introduction over forty years ago. Make is great at expressing build steps concisely and is not specific to (insert language here) projects. It is very good at incremental builds, which can save a lot of time when you rebuild after changing one or two files in a large project. G

> Make has been around long enough to have solved problems that newer build tools are only now discovering for themselves.

> ... Make is still widely used. But I think that it is underrepresented in (insert language here) development. You are more likely to see a Makefile in a C or C++ project, for example. --From [The Lost Art of the Makefile](https://www.olioapps.com/blog/the-lost-art-of-the-makefile/)

However, as is goes with Make, it can be a slippery slope as Makefiles themselves can spiral and become projects of their own. Thus this project is born, this is __shaving the Makefile Yak__ so each project does not have to. 

### BAM Docker Sizes

| Image                            |    size | 
| -------------------------------- | ------: | 
| Base Alpine image                | 2.68 MB |
| Base Alpine with Bash            | 3.46 MB | 
| Base Alpine with bash5 and make4 | 3.56 MB | 

Its worth the extra `1 MB`, even unzipped, BAM only adds `2.5 MB`

## Make as a wrapper

* In most cases we dont try to duplicate in Make what another build tool is doing for a language. 
* Gradle, maven, gulp, webpack, whatever ... are good for their repective languages. But they are not so great when you are trying to remeber the commands for building, testing, starting and deploying. 
* creating NPM scripts as your projects starting point for example has many limitations. 
* when going to a java or python project, `npm build` or `npm start` wont work unless I have npm. 
* we can have a standard `make build` and `make test` that works across all projects types and calls out to the respective build too commands. 

## Yggdrasil

```bash

├── bin        # core and common bash scripts
├── docs       # misc docs and generated shell docs
├── examples   # some basic playground examples
├── k8s        # common kubernetes helpers such docmark manifest 
├── makefiles  # base makefiles that can be included in a projects Makefile
└── tests      # Bats tests, run with `make check`

```

## Assumptions about the build environment

The goal is to keep the dependencies light for base functionality and install whats needed on demand (such as for bats and git-secret). Whether your on your local dev machine or in a docker on a CI much of whats here assumes the following for a base shipkit environment.

Make version: If you are on a mac then you probably have make 3.81 which was released back in 2006, when i had hair. This project needs a 4+ verion. `brew install make` and then follow suggestion on adding PATH so you can use `make` and not 
`gmake` so yu get the bash_completion
- `bash` is available. 
- `awk`, `grep` and `sed`, attempts are made to keep it compatible across gnu and mac os.
- `git`
- `ssh`
- `curl`

Depending on the project type, languages and what `makes` you include the following may also be needed
- `gnupg` for git-secret and encryption
- `java` - we use zulu from [Azul](https://www.azul.com/)
- `python`
- `node and npm`

## Setup

best best is to take a look at https://github.com/yakworks/gorm-tools for a spring/grails example

WIP for a node and python links


## Style Guides

https://www.conventionalcommits.org/en/v1.0.0/
https://style-guides.readthedocs.io/en/latest/makefile.html
https://google.github.io/styleguide/shellguide.html

on bash from google style guide
>Executables should have no extension (strongly preferred) or a .sh extension. Libraries must have a .sh extension and should not be executable.

we will add that if they are both, meaning they can be run or sourced in as a lib then the default is not .sh extension

## Versions and Upgrade Notes

Follow semantic versioning. 

### 2.0 upgrade notes

#### Terminology

**publishable**
: One of:
  - A library will be published to a repository, such as maven or npm. 
  - A docker image will be published on docker hub.
  - A deployment/cronjob/resource will be pushed to kubernetes.
    - It can be a snapshot or a production release.
    - In k8s terms it can be something that is staging, qa or production. 
  
**PUBLISHABLE_BRANCH**
: A github branch which is publishable. A successful build here will push something somewhere.

**PUBLISH_BRANCH_DEVREGEX**
: Can be set so it matches branch names that can ONLY publish development/snapshot versions
  IE: release=false , snapshot=true, IS_SNAPSHOT=true.

**snapshot**
: An _incremental, unversioned, mutable_ component. Used to indicate a development or bleeding edge or development release. Has a similar meaning in different contexts:
  - __github tag__: A snapshot is a movable tag indicating the latest development on a branch.
    - A snapshot tag does not always point to exactly the same code.
    - It cannot be built at one time and then rebuilt at a later time and be guaranteed the same result.
  - __repository tag__: Similar to the github tag, but for built libraries or apps which are published to _maven_, _npm_, _docker hub_, or some other repository where others can pull it and use it.
    - A snapshot repository tag indicates an application or library which was built from snapshot/incremental code.
    - The version number is something like `14.3.21-snapshot`
    - Pulling a snapshot tag from a repository at a later date will get possibly different content.
  - __build flag__: A true/false build variable specifying that the build should or should not be a snapshot.
    - __snapshot=true__ means that the build product will be __unversioned/incremental__.
      - The build can contain both versioned and snapshot components.
      - The build cannot be reliably reproduced by building again at a later date.
      - Good only for development and testing, __cannot be used in production__.
      - The version number of the current project is not changed. If the previous version was `14.3.21-snapshot` then the current build's version will be `14.3.21-snapshot`.
    - __snapshot=false__ means that the result will be __versioned/immutable/non-incremantal__.
      - The build must only contain released/non-incremental (versioned) components.
      - The version number is something like `14.3.21`
      - The version number will be incremented. If the previous version was `14.3.21` then the current will be `14.3.22`.
      - After a successful build/test, github is tagged.
      - The presence of a snapshot dependency in a build using `snapshot=false` must deliberately fail.
      - The build can be recreated at a later date with the exact same executable result.
      - The build product may be released/published

**release** or **releasable**
: A frozen or immutable version. The opposite of __snapshot__ above. Built with `snapshot=false`.
  A successful build will push the product somewhere, as in maven or npm. It can't be overwritten once it published. If it is a release then its will also of course 
  have to be publishable. Something that is released will also publish or deploy as explained above. but it will NOT even be a snapshot/dev version. 

  A release goes through a full release process cycle to automatically bump version, push a v tag/release to github and roll the version number in version.properties. 

#### Variable names changed

  - __IS_RELEASABLE__ stays the same and means its not a snapshot version, its on a branch that can be released (a publishable branch), not on a dev branch and user has permissions to do release. 
  - in `1.x` __PUBLISHABLE__ branches were called __RELEASABLE_BRANCH__.
    so:
    - `RELEASABLE_BRANCH` -> `PUBLISHABLE_BRANCH`
    - `RELEASE_BRANCH_REGEX` -> `PUBLISH_BRANCH_REGEX`
    - `RELEASABLE_BRANCH_OR_DRY_RUN` -> `PUBLISHABLE_BRANCH_OR_DRY_RUN`
    - etc.

#### Upgrade

- Search across app for `RELEASABLE_BRANCH` and change `build.yml` for new var name.
- change `version.properties` so that `snapshot=true` -> `release=false` so it operates in affirmative.
  - When `release=false`, then `IS_SNAPSHOT` will still be true.
  - When `release=true` then `IS_SNAPSHOT=false`
- if on `PUBLISHABLE_BRANCH` the build will do full release cycle.  

- Change `build.yml` so that `version_set_snapshot` -> `release_reset_flag`

- If using with gradle plugin `org.yakworks:gradle-plugins` version must be >= 2.7.3

## References

[See here for refs](docs/refs.md)
