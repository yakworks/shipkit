# BAM (bash and make) CI/CD Tool

BAM (Bash And Make) Bash scripts and makefiles based CI/CD tool. 
- ship every change to production without hassle. 
- Automated versioning, generating release notes
- Documentation builder
- Automated publishing

For a standardized way to build, test and deploy across projects that stays out of your way, no matter what the language.

<!-- TOC orderedlist:false -->

- [Verisons](#verisons)
    - [upgrade notes](#upgrade-notes)
- [Bash Scripts Usage Docs](#bash-scripts-usage-docs)
- [Why?](#why)
    - [Why Bash?](#why-bash)
    - [Why Make?](#why-make)
- [Make as a wrapper](#make-as-a-wrapper)
- [Assumptions about the build environment](#assumptions-about-the-build-environment)
- [Setup](#setup)
- [style guides we endeveur to follow](#style-guides-we-endeveur-to-follow)
- [References](#references)

<!-- /TOC -->

## Verisons

Follow semantic verioning. 

### 2.0 upgrade notes

__terminology.__

- **publishable** : publishable means it will be publish a lib to a repository, such as maven or npm. 
  It can also mean it will deploy a docker image or push a deploment to kuberenetes. 
  It can be a snapshot or a production release. In k8s terms it can be something that is staging, qa or production. 
  a PUBLISHABLE_BRANCH means its a branch that will push something somewhere. 
  PUBLISH_BRANCH_DEVREGEX can be set so it matches banch names that can ONLY publish development/snapshot versions
  IE: release=false , snapshot=true, IS_SNAPSHOT=true. 

- **release** or **releasable**: A `release` or `releasable` means its a production or frozen version. Such as in maven or npm
  its cant be overriten once it published. If is a release then its will also of course have to be publishable. 
  Something that is released will also publish or deploy as exmplained above. but it will NOT even be a snapshot/dev version. 
  A release goes through a full release process cycle to automatically bump version, push a v tag/release to github and 
  roll the version number in version.properties. 

- variable names changed. 
  - IS_RELEASABLE stays the same and means its not a snapshot version, its on a branch that can be released (a publishable branch), not on a dev branch and user has permissions to do release. 
  - in 1.x PUBLISHABLE branches were called RELEASABLE_BRANCH
    so RELEASABLE_BRANCH renamed to PUBLISHABLE_BRANCH, 
    RELEASE_BRANCH_REGEX -> PUBLISH_BRANCH_REGEX,  RELEASABLE_BRANCH_OR_DRY_RUN -> PUBLISHABLE_BRANCH_OR_DRY_RUN etc.. 
    search across app for RELEASABLE_BRANCH and change build.yml for new var name.

  - change version.properties snapshot=true to release=false. operates in affirmative, 
    when release=false, then IS_SNAPSHOT will still be true. when release=true then IS_SNAPSHOT=false and 
    if on PUBLISHABLE_BRANCH will do full release cycle.  

  - the property version_set_snapshot should be changed to release_reset_flag=, check build.yml

  - is using with gradle plugin `org.yakworks:gradle-plugins` version must be >= 2.7.3

## Bash Scripts Usage Docs

  [See Here For Shipkits Bash Scripts](docs/USAGE.md)

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

### Why Bash?

Yes we need it. Its pretty much every where. And when using an alpine docker image, Bash only adds about 800k compressed, and 2.2 mb uncompressed. Its silly not use its plethora of features for scripting. 

| Image                                                        | size    | uncompressed |
|--------------------------------------------------------------|--------:|-------------:|
| Base Alpine image                                            | 2.68 MB | 5.6 MB       |
| Alpine with Bash                                             | 3.46 MB | 7.75 MB      |
| Alpine with bash, make                                       | 3.56 MB | 7.96 MB      |
| Alpine with Bash, Make, Curl                                 | 4.56 MB | 10.04 MB     |
| Alpine with Bash, Make, Curl <br> gnupg, git, openssh-client | 20.6 MB | 46.72 MB     |

### Why Make?

From [The Lost Art of the Makefile](https://www.olioapps.com/blog/the-lost-art-of-the-makefile/)

> Make is a general-purpose build tool that has been improved upon and refined continuously since its introduction over forty years ago. Make is great at expressing build steps concisely and is not specific to (insert language here) projects. It is very good at incremental builds, which can save a lot of time when you rebuild after changing one or two files in a large project. G

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

## Setup

best best is to take a look at https://github.com/yakworks/gorm-tools for a spring/grails example

WIP for a node and python links


## style guides we endeveur to follow

https://www.conventionalcommits.org/en/v1.0.0/
https://style-guides.readthedocs.io/en/latest/makefile.html
https://google.github.io/styleguide/shellguide.html

on bash from google style guide
>Executables should have no extension (strongly preferred) or a .sh extension. Libraries must have a .sh extension and should not be executable.

we will add that if they are both, meaning they can be run or sourced in as a lib then the default is not .sh extension


## References

[See here for refs](docs/refs.md)
