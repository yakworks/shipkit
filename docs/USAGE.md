# Usage Docs
### 📇 Index

* [changelog](#changelog)
  * [update_changelog()](#update_changelog)
* [circle](#circle)
  * [circle.trigger()](#circletrigger)
* [docker_tools](#docker_tools)
  * [docker.login()](#dockerlogin)
  * [docker.stop()](#dockerstop)
  * [docker.remove()](#dockerremove)
  * [docker.start()](#dockerstart)
  * [docker.create_network()](#dockercreate_network)
* [docmark](#docmark)
  * [docmark.copy_readme()](#docmarkcopy_readme)
  * [docmark.copy_groovydoc_to_api()](#docmarkcopy_groovydoc_to_api)
  * [docmark.run()](#docmarkrun)
  * [docmark.shell()](#docmarkshell)
* [dotenv](#dotenv)
  * [dotenv.load()](#dotenvload)
* [git_tools](#git_tools)
  * [init_github_vars()](#init_github_vars)
  * [project_fullname_from_git_remote()](#project_fullname_from_git_remote)
  * [verify_git_user()](#verify_git_user)
  * [current_git_branch()](#current_git_branch)
  * [git_clone_pages()](#git_clone_pages)
  * [git_push_pages()](#git_push_pages)
  * [config_bot_user()](#config_bot_user)
  * [init_gh_pages()](#init_gh_pages)
  * [git_tag()](#git_tag)
  * [git_push_tags()](#git_push_tags)
  * [hasAppChanges()](#hasappchanges)
  * [hasDocChanges()](#hasdocchanges)
  * [git_debug()](#git_debug)
* [github](#github)
  * [github.create_release()](#githubcreate_release)
* [gradle_tools](#gradle_tools)
  * [gradle.merge_test_results()](#gradlemerge_test_results)
  * [_copy_test_results()](#_copy_test_results)
  * [gradle.transform_to_java_props()](#gradletransform_to_java_props)
* [heredoc_tpl](#heredoc_tpl)
* [init_env](#init_env)
  * [make_env()](#make_env)
  * [make_env_init()](#make_env_init)
  * [init_env()](#init_env)
  * [init_defaults()](#init_defaults)
  * [init_from_build_yml()](#init_from_build_yml)
  * [make_some_vals_lowercase()](#make_some_vals_lowercase)
  * [init_versions()](#init_versions)
  * [set_snapshot()](#set_snapshot)
  * [circle_init_env()](#circle_init_env)
  * [init_db_env()](#init_db_env)
  * [createEnvFile()](#createenvfile)
  * [parse_bot_env_file()](#parse_bot_env_file)
  * [load_env()](#load_env)
  * [load_custom_sh_or_env()](#load_custom_sh_or_env)
* [jbuilder_docker](#jbuilder_docker)
  * [builderStart()](#builderstart)
  * [db_start()](#db_start)
  * [db-start()](#db-start)
  * [wait_for_mysql()](#wait_for_mysql)
  * [wait_for_sqlserver()](#wait_for_sqlserver)
* [kube_tools](#kube_tools)
  * [kube.process_tpl()](#kubeprocess_tpl)
  * [kube.create_namespace()](#kubecreate_namespace)
  * [kube.ctl()](#kubectl)
  * [kube.apply()](#kubeapply)
* [make_shell](#make_shell)
* [makechecker](#makechecker)
  * [makechecker.lint()](#makecheckerlint)
  * [makechecker.lint_files()](#makecheckerlint_files)
  * [makechecker.find_targets()](#makecheckerfind_targets)
* [sed_tpl](#sed_tpl)
  * [build_sed_args()](#build_sed_args)
* [semver](#semver)
  * [replace_version()](#replace_version)
  * [bump_version_file()](#bump_version_file)
  * [update_package_json()](#update_package_json)
  * [updateVersionFile()](#updateversionfile)
  * [bump_patch()](#bump_patch)
* [setVar](#setvar)
  * [setVar()](#setvar)
  * [evalVar()](#evalvar)
  * [putVar()](#putvar)
  * [add_build_vars()](#add_build_vars)
  * [log-vars()](#log-vars)
* [shellchecker](#shellchecker)
  * [shellcheck.lint_fix()](#shellchecklint_fix)
  * [find_shellcheck_targets()](#find_shellcheck_targets)

## changelog

helpers to create and update a changelog

### update_changelog()

updates the changelog, does a bunch of git diff work to get changes

[See examples here]( https://gist.github.com/kingkool68/09a201a35c83e43af08fcbacee5c315a)

* __🔌 Args__

  * __$1__ (any): the current dev version
  * __$2__ (any): the previous published version
  * __$3__ (any): the changelog filename
  * __$4__ (any): the PROJECT_FULLNAME in the format of owner/repo, such as yakworks/gorm-tools

* __🔢 Exit Codes__

  * __1__ : published_version does not exists

## circle

utils for working with CI circle and publishing,

### Description


to trigger a circle repo
~~~bash
./circle.sh trigger "yakworks/shipkit" "g22kljf2324....."
~~~

### circle.trigger()

uses curl to trigger a pipeline

* __🔌 Args__

  * __$1__ (any): the owner/repo
  * __$2__ (any): the circle token

## docker_tools

helper functions for running docker

### Description

Common helper functions for running docker images and logging into dockerhub
Use compose when possible but these are used for quickly bringing up a docker
docmark makes heavy use of this

### docker.login()

login to docker hub

* __🔌 Args__

  * __$1__ (any): docker hub user
  * __$2__ (any): docker hub password

### docker.stop()

removes the docker

* __🔌 Args__

  * __$1__ (any): the docker name

### docker.remove()

removes the docker

* __🔌 Args__

  * __$1__ (any): the docker name

### docker.start()

starts a docker (docker run) if its not already running

* __🔌 Args__

  * __$1__ (any): the name of the docker as in `--name=$1`
  * __$2__ (any): the arguments that would normall passed to a docker run

### docker.create_network()

create a docker network if it does not exist

* __🔌 Args__

  * __$1__ (any): network name

## docmark

functions for running the yakworks docmark mkdocs variant

### Description

functions for running the yakworks docmark mkdocs variant
depends on bin/github_pages script

### docmark.copy_readme()

Copies readme, updates version and replaces links that went into docs

* __🔌 Args__

  * __$1__ (any): the version to update

### docmark.copy_groovydoc_to_api()

builds the groovydocs and copies them into site/api

### docmark.run()

runs the docmark

### docmark.shell()

use this to open shell and test circle commands

## dotenv

default functions to setup BUILD_VARS

### Description

BUILD_VARS are used to create a makefile.env
that is imcluded at the start of the Makefile to share vars

### dotenv.load()

parses the env file, eval and load into BUILD_VARS

* __🔌 Args__

  * __$1__ (any): the env file to parse
  * __$2__ (any): true if we want to override all variables that might already be set
  * __$3__ (any): the regex exclude pattern for keys such as "foo|bar|baz"

## git_tools

Github and git helpers.

### Description

MOSTLY HERE FOR REF, SEE git-tools.make as that the core of it.
uses the variables set from gradle/build.yml

### init_github_vars()

initialize variables for github
will try and constuct PROJECT_FULLNAME from git config if not passed in

* __🔌 Args__

  * __$1__ (any): the PROJECT_FULLNAME in the format of owner/repo, if not passed in then it will constuct it

### project_fullname_from_git_remote()

set the PROJECT_FULLNAME github slug from git config --get remote.origin.url
based on whther its https or ssh git

### verify_git_user()

checks is a git user is setup, and if not sets up the bot user, used in CI.

### current_git_branch()

shows the current git branch

### git_clone_pages()

clones gh-pages into the build directory
--

* __🔌 Args__

  * __$1__ (any): PAGES_BRANCH the branch, normally gh-pages
  * __$2__ (any): PAGES_BUILD_DIR the dir to clone it to, build/gh-pages
  * __$3__ (any): PROJECT_FULLNAME the full name

### git_push_pages()

in build/gh-pages commits and pushes gh pages

* __🔌 Args__

  * __$1__ (any): PAGES_BRANCH the branch, normally gh-pages
  * __$2__ (any): PAGES_BUILD_DIR the dir to clone it to, build/gh-pages
  * __$3__ (any): PROJECT_FULLNAME the full name

### config_bot_user()

sets up the git user info for commit and push
should run only if CI=true. Pass in what you want in github with email
matching account in github

* __🔌 Args__

  * __$1__ (any): bot user name
  * __$2__ (any): bot user email

### init_gh_pages()

### git_tag()

creates a git tag

* __🔌 Args__

  * __$1__ (any): the tag nam
  * __$2__ (any): the commit message

### git_push_tags()

### hasAppChanges()

checks a commit rangs to see if somethign other than docs has changed

* __🔌 Args__

  * __$1__ (any): the commit range like 911ff1ea1fa5...a883787c2f50

* __📺 Stdout__

  * the list of file changes, empty if nothing

### hasDocChanges()

checks a commit rangs to see if docs have changed

* __🔌 Args__

  * __$1__ (any): the commit range like 911ff1ea1fa5...a883787c2f50

* __📺 Stdout__

  *  the list of file changes, empty if nothing

### git_debug()

Just a helper to show variables which can be useful for debugging

## github

### github.create_release()

## gradle_tools

### gradle.merge_test_results()

### _copy_test_results()

### gradle.transform_to_java_props()

## basic tempalate variable replacement using heredoc

## init_env

### make_env()

LEAVE THIS INDENT, heredoc needs to to look this way

### make_env_init()

### init_env()

### init_defaults()

### init_from_build_yml()

### make_some_vals_lowercase()

### init_versions()

### set_snapshot()

### circle_init_env()

### init_db_env()

### createEnvFile()

### parse_bot_env_file()

### load_env()

### load_custom_sh_or_env()

## jbuilder_docker

### builderStart()

### db_start()

### db-start()

### wait_for_mysql()

### wait_for_sqlserver()

## runs sed on the kubernetes tpl.yml template files to update and replace variables with values

### kube.process_tpl()

### kube.create_namespace()

### kube.ctl()

### kube.apply()

## make_shell

## makechecker

### makechecker.lint()

Lints a one or more dirs
The main issue to check for is lines starting with 4 spaces

* __🔧 Example__

  ~~~bash
  makechecker lint makefiles
  ~~~

* __🔌 Args__

  * __$@__ (any): {array} one or more dirs

### makechecker.lint_files()

Lint one or more files

* __🔌 Args__

  * __$@__ (any): {array} list of files

* __📺 Stdout__

  * # @returns

### makechecker.find_targets()

gets all files that either start with Makefile or have .make extension

* __🔌 Args__

  * __$@__ (any): {array} one or more dirs

## basic tempalate variable replacement using sed

### build_sed_args()

## semver

### replace_version()

### bump_version_file()

### update_package_json()

### updateVersionFile()

### bump_patch()

## setVar

### setVar()

### evalVar()

### putVar()

### add_build_vars()

### log-vars()

## runs the shellcheck on the passed one or more directories

### shellcheck.lint_fix()

uses the pattern `shellcheck -f diff bin/* | git apply` to fix what can be automatically fixed

$@ - {array} one or more dirs

### find_shellcheck_targets()

collects the files names from one or more directories into SHELLCHECK_TARGETS variable
will recursively spin in and only get the files that are x-shellscript mime type

$@ - {array} one or more dirs


