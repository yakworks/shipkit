# BAM (bash and make) CI/CD Tool

BAM (Bash And Make) Bash scripts and makefiles based CI/CD tool. 
- ship every change to production without hassle. 
- Automated versioning, generating release notes
- Documentation builder
- Automated publishing

For a standardized way to build, test and deploy across projects that stays out of your way, no matter what the language.

## Why?

From https://github.blog/2015-06-30-scripts-to-rule-them-all/

> We have a lot of software running our products and company. We also have a lot of potential contributing members. Being able to get from git clone to an up-and-running project in a development environment is imperative for fast, reliable contributions. A consistent bootstrapping experience across all our projects reduces friction and encourages contribution.

With practically every software project, developers need to perform the following tasks:

- bootstrap
- run linter/code quality checks
- run tests
- run continuous integration
- start the app

We have normalized on a set of `Bash` scripts and `Make` targets for all of our projects that individual contributors will be familiar with the second after they clone a project. 

## Why Bash?

Yes we need it. Its pretty much every where. And when using a small alpine docker image, adding bash only adds about 2.5 mb

| Image                                                        | size    | uncompressed |
|--------------------------------------------------------------|--------:|-------------:|
| Base Alpine image                                            | 2.68 MB | 5.6 MB       |
| Alpine with Bash                                             | 3.46 MB | 7.75 MB      |
| Alpine with bash, make                                       | 3.56 MB | 7.96 MB      |
| Alpine with Bash, Make, Curl                                 | 4.56 MB | 10.04 MB     |
| Alpine with Bash, Make, Curl <br> gnupg, git, openssh-client | 20.6 MB | 46.72 MB     |

## Why Make?

From [The Lost Art of the Makefile](https://www.olioapps.com/blog/the-lost-art-of-the-makefile/)

> Make is a general-purpose build tool that has been improved upon and refined continuously since its introduction over forty years ago. Make is great at expressing build steps concisely and is not specific to (insert language here) projects. It is very good at incremental builds, which can save a lot of time when you rebuild after changing one or two files in a large project.

> Make has been around long enough to have solved problems that newer build tools are only now discovering for themselves.

> ... Make is still widely used. But I think that it is underrepresented in (insert language here) development. You are more likely to see a Makefile in a C or C++ project, for example.

However, as is goes with Make, it is a slippery slope with Makefiles themselves become projects of their own. Thus this project is born, shaving the Makefile Yak so your project does have to. 

## Make as a wrapper

In most cases we dont try to duplicate in Make what another build tool is doing for a language. Gradle, maven, gulp, webpack, whatever ... are good for their repective languages. But they are not so great when you are trying to remeber the commands for building, testing, starting and deploying. creating NPM scripts as your projects starting point for example has many limitations. And when going to a java or python project, `npm build` or `npm start` wont work unless I have npm. But we can have a standard `make build` and `make test` that works across all projects and calls out to the respective build too commands. 

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

## Good reads

Lost art of the makefile

- https://www.olioapps.com/blog/the-lost-art-of-the-makefile/
- https://3musketeers.io/

12 factor app is the philosophy

- https://12factor.net

## style guides we endeveur to follow

https://www.conventionalcommits.org/en/v1.0.0/
https://style-guides.readthedocs.io/en/latest/makefile.html
https://google.github.io/styleguide/shellguide.html


## Setup

best best is to take a look at https://github.com/yakworks/gorm-tools for a spring/grails example

WIP for a node and python links

## MAKE

https://github.com/wurosh/cake
https://gitlab.com/internet-cleanup-foundation/web-security-map/-/blob/master/Makefile

## Semver and Conventional Commits
https://www.conventionalcommits.org/en/v1.0.0/
https://github.com/semantic-release/semantic-release
https://dwmkerr.com/conventional-commits-and-semantic-versioning-for-java/

https://dev.to/craicoverflow/enforcing-conventional-commits-using-git-hooks-1o5p
https://github.com/craicoverflow/sailr

## related

- https://github.com/semantic-release/semantic-release
- 

Good make samples that this was taken from
ideas pulled from https://tech.davis-hansson.com/p/make/
and https://github.com/martinwalsh/ludicrous-makefiles	

## links for using make and docker
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

## bash

- http://bash3boilerplate.sh
- http://redsymbol.net/articles/unofficial-bash-strict-mode/

## versioning example

- https://github.com/mvanholsteijn/docker-makefile

## docker makefiles
- https://philpep.org/blog/a-makefile-for-your-dockerfiles
- https://stackoverflow.com/questions/44969605/incrementally-build-docker-image-hierarchy-with-makefile
