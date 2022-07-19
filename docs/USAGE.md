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

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function update_changelog(){
  
    # the GITHUB_LINK_URL such as https://github.com/yakworks/gorm-tools to make anchors in changelog
    : "${GITHUB_LINK_URL:=https://github.com/$4}"
    # [ "$GITHUB_LINK_URL" ] || GITHUB_LINK_URL="https://github.com/$4"
    # Repo URL to base links off of
    local LATEST_TAG="v$1" # example v6.1.12
    local published_version="v$2" # example v6.1.11
    local changelogName=$3
  
    # Get a list of all tags in reverse order
    # Assumes the tags are in version format like v1.2.3
    local gitTags
    gitTags=$(git tag -l --sort=-version:refname)
    # make it into an array
    TAGS=()
    if [ "$gitTags" ]; then
      # shellcheck disable=SC2206 # we don't quote when creating arrays or it would be a single array
      TAGS=($gitTags)
    fi
  
    local MARKDOWN="### $LATEST_TAG\n"
    MARKDOWN+='\n'
  
    local tagRange="$published_version..HEAD"
    local COMMITS=""
    # if published_version is falsy then its an initial release so blank out range to get all of it
    # if this is not what you want then create a tag that starts with a v
    # and set publishedVersion to that tag without the v prefix in version.props
    if falsy "$2"; then
      tagRange=""
      MARKDOWN+='Initial Release'
    else
      # shellcheck disable=SC2076,SC2199 # array is done like this intentionally
      if ! array.contains "$published_version" "${TAGS[@]}"; then
        echo "Error creating changelog - publishedVersion $published_version does not exists"
        false
        return
      fi
      MARKDOWN+="[Full Changelog]($GITHUB_LINK_URL/compare/$published_version...$LATEST_TAG)"
  
      # We only get the commit hash so we don't have to deal with a bunch of ugly parsing
      # See Pretty format placeholders at https://git-scm.com/docs/pretty-formats
      COMMITS=$(git log "$tagRange" --pretty=format:"%H")
    fi
  
    # Loop over each commit and look for merged pull requests
    for COMMIT in $COMMITS; do
      # Get the subject of the current commit
      local SUBJECT=$(git log -1 "${COMMIT}" --pretty=format:"%s")
      # echo "SUBJECT $SUBJECT"
      # If the subject contains [ci skip] then skip it
      local NOT_SKIPPED=$( echo "$SUBJECT" | grep -v -E "\[ci skip\]" )
      if [[ $NOT_SKIPPED ]]; then
        # AUTHOR_NAME=$(git log -1 ${COMMIT} --pretty=format:"%an")
        # AUTHOR_EMAIL=$(git log -1 ${COMMIT} --pretty=format:"%ae")
  
        MARKDOWN+='\n'
        MARKDOWN+="- $SUBJECT [link]($GITHUB_LINK_URL/commit/$COMMIT)"
        # Get the body of the commit
        # local commit_body="$(git log -1 ${COMMIT} --pretty=format:"%b")"
        # TODO scrambles it up, not sure what kind of line feed CR thingys on in there but
        # can't figure out the voodoo needed to do this
        # if [ "$commit_body" ]; then
        #   echo 'has body'
        #   git log -1 ${COMMIT} --pretty=format:"%b" | sed '/^[[:space:]]*$/d' > log.txt
        #   local back_in=$(cat log.txt)
        #   echo "$back_in"
        #   # echo "$commit_body" | sed '/^[[:space:]]*$/d'
        #   local body_esc=`escape_json_string $back_in`
        #   echo "body_esc: $body_esc"
        #   MARKDOWN+='\n'
        #   MARKDOWN+="$body_esc"
        # fi
      fi
    done
    MARKDOWN+='\n'
    # put CHANGELOG_CHUNK.md in build dir so it can be used later when creating release in github
    echo -e "$MARKDOWN" > "$BUILD_DIR/CHANGELOG_RELEASE.md"
  
    # make sure changelog file exists
    [ ! -f "$changelogName" ] && touch "$changelogName"
  
    local changelog=$(cat "$changelogName")
    # prepend it
    echo -e "$MARKDOWN\n$changelog" > "$changelogName"
    # Save our markdown to a file
    #echo -e $MARKDOWN > CHANGELOG.md
  }
  ~~~

  <details>

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

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  circle.trigger(){
    curl --location --request POST \
  		"https://circleci.com/api/v2/project/github/$1/pipeline" \
  		--header 'Content-Type: application/json' \
  		-u "$2:"
  }
  ~~~

  <details>

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
    CIRCLE_COMPARE_URL=$(cat CIRCLE_COMPARE_URL.txt || true)
    # echo "CIRCLE_COMPARE_URL $CIRCLE_COMPARE_URL"
    echo "$CIRCLE_COMPARE_URL" | rev | cut -d/ -f1 | rev
  }
  ~~~

  <details>

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

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function docker.login {
    echo "$2" | docker login -u "$1" --password-stdin
  }
  ~~~

  <details>

### docker.stop()

removes the docker

* __🔌 Args__

  * __$1__ (any): the docker name

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function docker.stop {
    if [ "$(docker ps -aq -f name="${1}")" ]; then
      docker stop "${1}" || true
    fi
  }
  ~~~

  <details>

### docker.remove()

removes the docker

* __🔌 Args__

  * __$1__ (any): the docker name

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function docker.remove {
    if [ "$(docker ps -aq -f name="${1}")" ]; then
       docker stop "${1}" || true
       docker rm "${1}" || true
       # echo "if this following shows errors 'No such container:' next its fine as its doing a force rm"
    fi
  }
  ~~~

  <details>

### docker.start()

starts a docker (docker run) if its not already running

* __🔌 Args__

  * __$1__ (any): the name of the docker as in `--name=$1`
  * __$2__ (any): the arguments that would normall passed to a docker run

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function docker.start {
    if [ ! "$(docker ps -q -f name="${1}")" ]; then
      # just in case it does exist but with status=exited fire a remove
      docker.remove "${1}"
      docker run --name="${1}" "${@:2}"
    fi
  }
  ~~~

  <details>

### docker.create_network()

create a docker network if it does not exist

* __🔌 Args__

  * __$1__ (any): network name

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function docker.create_network {
    if [ ! "$( docker network ls | grep "$1" )" ]; then
      docker network create "$1"
      echo "$1 network created"
    fi
  }
  ~~~

  <details>

## docmark

functions for running the yakworks docmark mkdocs variant

### Description

functions for running the yakworks docmark mkdocs variant
depends on bin/github_pages script

### docmark.copy_readme()

Copies readme, updates version and replaces links that went into docs

* __🔌 Args__

  * __$1__ (any): the version to update

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function docmark.copy_readme {
    local index_md=docs/index.md
    rm -f "$index_md"
    cp README.md "$index_md"
    [[ "$1" ]] && replace_version "$1" "$index_md"
    # replace the (docs/ text in links as they are in same dir now, ex [foo](docs/bar.md) will become [foo](bar.md)
    sed -i.bak -e "s~(\s*docs\/~(~g" "$index_md" && rm "${index_md}.bak"
    return 0
  }
  ~~~

  <details>

### docmark.copy_groovydoc_to_api()

builds the groovydocs and copies them into site/api

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function docmark.copy_groovydoc_to_api {
    cp -r build/docs/groovydoc build/site/api || true
  }
  ~~~

  <details>

### docmark.run()

runs the docmark

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function docmark.run {
    docker.start "$DOCMARK_DOCKER_NAME" -it \
      -w /project \
      -p 8000:8000 \
  	  -v "$(pwd)":/project:delegated  \
  		"$DOCMARK_DOCKER_IMAGE"
  }
  ~~~

  <details>

### docmark.shell()

use this to open shell and test circle commands

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function docmark.shell {
    docker.start "$DOCMARK_DOCKER_NAME" --rm -it \
      --entrypoint /bin/bash \
      -p 8000:8000 \
  	  -v "$(pwd)":/project  \
      -e GITHUB_TOKEN="${GITHUB_TOKEN}" \
  		"$DOCMARK_DOCKER_IMAGE"
  
    # GITHUB_TOKEN gitub token is passed from local env to docmark so we can test publish
  }
  ~~~

  <details>

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

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function dotenv.load {
    local env_file="${1}"
    local overrideVar="${2:-false}"
    local exclude_pattern="${3:-}"
  
    # check if file exists, and return if not
    if [ ! -f "$env_file" ]; then
      return 0
    fi
  
    local lines=$(cat "$env_file")
    local line key
  	while IFS= read -r line; do
      # trim leading whitespace
  		line=${line#"${line%%[![:space:]]*}"}
      # trim trailing whitespace
  		line=${line%"${line##*[![:space:]]}"}
      # move on if its a comment
  		if [[ ! "$line" || "$line" == '#'* ]]; then continue ; fi
      # echo "line $line"
      var_name="${line%%=*}"
      val="${line#*=}"
  
      if [[ "$exclude_pattern" && "$var_name" =~ ^($exclude_pattern).*$ ]]; then
        echo "$var_name is protected and can not be set in $1. Set in shell cmd or as make parameter if its really neccesary to override"
        echo -e "example: 'make log-vars $var_name=foo' or '$var_name=foo make log-vars'"
        return 1
      fi
  
      # see if we already have a value set for this var
      local currentEnvVarVal="${!var_name:-}"
  
      if [[ "$line" == *"+="* ]]; then
        #if line is something like "foo+=(bar)" then its an array getting vals added to it so always set it
        eval "${line}"
      elif truthy "$overrideVar" ; then
        eval "${line}"
      elif [ ! "$currentEnvVarVal" ]; then
        # its not already set so eval it
        eval "${line}"
      fi
      # now add it to the build vars
      add_build_vars "$var_name"
      # if truthy "$overrideVar" ; then
      #   putVar "$key" "$val"
      # else
      #   setVar "$key" "$val"
      # fi
  	done <<<"$lines"
    # log-vars
  }
  ~~~

  <details>

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

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function init_github_vars {
    local ghFullName="${1:-$PROJECT_FULLNAME}"
    if [ ! "$ghFullName" ]; then
      echo "PROJECT_FULLNAME not set, trying `git config --get remote.origin.url`"
      project_fullname_from_git_remote
      # if it didn't get it then error
      [ ! "$PROJECT_FULLNAME" ] && echo "PROJECT_FULLNAME did not get setup" && return 1
      ghFullName="$PROJECT_FULLNAME"
    fi
  
    ##
    # echo "init_github_vars with PROJECT_FULLNAME $ghFullName"
    # keeps whats after last /
    # ```
    # GITHUB_REPO=${ghFullName##*/}
    # GITHUB_LINK_URL="https://github.com/${ghFullName}"
    # ```
    GITHUB_BASE_URL="github.com/${ghFullName}.git"
    GITHUB_URL="https://$GITHUB_BASE_URL"
    # echo "GITHUB_URL $GITHUB_URL"
    # For CI the git user token will be set in env var.
    if [[ $GITHUB_TOKEN ]]; then
      echo "adding GITHUB_TOKEN token to GITHUB_URL: $GITHUB_URL"
      # add the token
      GITHUB_URL="https://dummy:${GITHUB_TOKEN}@$GITHUB_BASE_URL"
    fi
  
    #echo "GITHUB_URL $GITHUB_URL"
    verify_git_user
  
    return 0
  }
  ~~~

  <details>

### project_fullname_from_git_remote()

set the PROJECT_FULLNAME github slug from git config --get remote.origin.url
based on whther its https or ssh git

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function project_fullname_from_git_remote {
    HAS_GIT="$(which git 2> /dev/null)" || true
    if [ ! "$HAS_GIT" ];then
      echo -e "\e[91mgit can't be located, not stable"; return 0
    fi
  
    local remoteUrl=$(git config --get remote.origin.url)
    if [[ $remoteUrl == git* ]];then
      PROJECT_FULLNAME=$(echo "$remoteUrl"  | cut -d: -f2 | cut -d. -f1)
    else
      PROJECT_FULLNAME=$(echo "$remoteUrl" | cut -d/ -f4,5 | cut -d. -f1)
    fi
    # echo $PROJECT_FULLNAME
  }
  ~~~

  <details>

### verify_git_user()

checks is a git user is setup, and if not sets up the bot user, used in CI.

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function verify_git_user {
  
    local hasGitUser=$(git config --global user.email || true)
    # see https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
    if [ ! "${hasGitUser}" ] || [ "$CI" ]; then
      echo "adding BOT_USER"
      : "${BOT_USER:=9cibot}"
      : "${BOT_EMAIL:=9cibot@9ci.com}"
      # echo "adding git user"
      config_bot_user $BOT_USER $BOT_EMAIL
    fi
  }
  ~~~

  <details>

### current_git_branch()

shows the current git branch

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function current_git_branch {
    git rev-parse --abbrev-ref HEAD
  }
  ~~~

  <details>

### git_clone_pages()

clones gh-pages into the build directory
--

* __🔌 Args__

  * __$1__ (any): PAGES_BRANCH the branch, normally gh-pages
  * __$2__ (any): PAGES_BUILD_DIR the dir to clone it to, build/gh-pages
  * __$3__ (any): PROJECT_FULLNAME the full name

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function git_clone_pages {
    local pagesBranch="${1:-$PAGES_BRANCH}"
    local pagesDir="${2:-$PAGES_BUILD_DIR}"
    [ "$GITHUB_URL" ] || init_github_vars "$3"
    mkdir -p build
    rm -rf "$pagesDir"
    git clone "$GITHUB_URL" "$pagesDir" -b "$pagesBranch" --single-branch --depth 1
  }
  ~~~

  <details>

### git_push_pages()

in build/gh-pages commits and pushes gh pages

* __🔌 Args__

  * __$1__ (any): PAGES_BRANCH the branch, normally gh-pages
  * __$2__ (any): PAGES_BUILD_DIR the dir to clone it to, build/gh-pages
  * __$3__ (any): PROJECT_FULLNAME the full name

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function git_push_pages {
    local pagesBranch="${1:-$PAGES_BRANCH}"
    local pagesDir="${2:-$PAGES_BUILD_DIR}"
    [ "$GITHUB_URL" ] || init_github_vars "$3"
    git -C "$pagesDir" add -A .
    git -C "$pagesDir" commit -a -m "CI Docs published [skip ci]" || true # or true so doesnt blow error if no changes
    git -C "$pagesDir" push -q "$GITHUB_URL" "$pagesBranch" || true
  }
  ~~~

  <details>

### config_bot_user()

sets up the git user info for commit and push
should run only if CI=true. Pass in what you want in github with email
matching account in github

* __🔌 Args__

  * __$1__ (any): bot user name
  * __$2__ (any): bot user email

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function config_bot_user {
    echo "config_bot_user with $1"
    git config credential.helper 'cache --timeout=120'
    git config --global user.email "$2"
    git config --global user.name "$1"
  }
  ~~~

  <details>

### init_gh_pages()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function init_gh_pages {
    [ "$GITHUB_URL" ] || init_github_vars
    mkdir -p build
    cd build
    rm -rf gh-pages
    git clone "$GITHUB_URL" $PAGES_BRANCH
    cd gh-pages
    git checkout --orphan $PAGES_BRANCH
    git rm -rf .
    echo "github pages site" > README.md
    push_gh_pages
  }
  ~~~

  <details>

### git_tag()

creates a git tag

* __🔌 Args__

  * __$1__ (any): the tag nam
  * __$2__ (any): the commit message

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function git_tag {
    git add .
    git commit -m "$2"
    git tag "$1"
  }
  ~~~

  <details>

### git_push_tags()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function git_push_tags {
    git push -q --tags "$GITHUB_URL" master
  }
  ~~~

  <details>

### hasAppChanges()

checks a commit rangs to see if somethign other than docs has changed

* __🔌 Args__

  * __$1__ (any): the commit range like 911ff1ea1fa5...a883787c2f50

* __📺 Stdout__

  * the list of file changes, empty if nothing

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function hasAppChanges {
    git diff "$1" --name-status | grep -v -E "(README\.md|mkdocs\.yml|docs/)" || true
  }
  ~~~

  <details>

### hasDocChanges()

checks a commit rangs to see if docs have changed

* __🔌 Args__

  * __$1__ (any): the commit range like 911ff1ea1fa5...a883787c2f50

* __📺 Stdout__

  *  the list of file changes, empty if nothing

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function hasDocChanges {
    git diff "$1" --name-status | grep -E "(README\.md|mkdocs\.yml|version.properties|docs/)" || true
  }
  ~~~

  <details>

### git_debug()

Just a helper to show variables which can be useful for debugging

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function git_debug {
    [ "$GITHUB_URL" ] || init_github_vars
    echo "PROJECT_FULLNAME: $PROJECT_FULLNAME"
    echo "GITHUB_BASE_URL: $GITHUB_BASE_URL"
    echo "GITHUB_URL: $GITHUB_URL"
    echo "BOT_USER: $BOT_USER"
    echo "BOT_EMAIL: $BOT_EMAIL"
  }
  ~~~

  <details>

## github

### github.create_release()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function github.create_release {
    if [ "${dry_run:-}" ]; then
  		echo "🌮 dry_run ->  github.create_release $@"
      return 0
  	fi
    # get body from
    local body=$(cat "$BUILD_DIR/CHANGELOG_RELEASE.md")
    local body_esc=`escape_json_string "$body"`
  
  ## LEAVE THIS INDENT, heredoc needs to to look this way
  local api_data=$(cat <<EOF
    {
      "tag_name":         "v$1",
      "target_commitish": "$2",
      "name":             "v$1",
      "draft":            false,
      "prerelease":       false,
      "body": "$body_esc"
    }
  EOF
  )
    echo "$api_data"
    # local rurl="https://api.github.com/repos/$3/releases"
    local curl_result=`curl -X POST -s -w "\n%{http_code}\n" \
      -H "Authorization: token $4" \
      -d "$api_data" \
      "https://api.github.com/repos/$3/releases"`
  
    if [ "`echo "$curl_result" | tail -1`" != "201" ]; then
      echo "FAILED - curl"
      echo "$curl_result"
      return 1
    fi
    local release_id=`echo "$curl_result" | sed -ne 's/^  "id": \(.*\),$/\1/p'`
    if [[ -z "$release_id" ]]; then
      echo "FAILED - release_id"
      echo "$curl_result"
      return 1
    fi
    echo "SUCCESS - github release id: $release_id"
  }
  ~~~

  <details>

## gradle_tools

### gradle.merge_test_results()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function gradle.merge_test_results {
    local projList="${1:-$PROJECT_SUBPROJECTS}"
    for project in $projList; do
      _copy_test_results "$project" "test-results"
      _copy_test_results "$project" "reports"
    done
  }
  ~~~

  <details>

### _copy_test_results()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function _copy_test_results {
    local dir="$1/build/$2/"
    if [ -d "${dir}" ]; then
      mkdir -p build/"$2"/"$1"
      cp -r "$dir" build/"$2"/"$1"
    fi
  }
  ~~~

  <details>

### gradle.transform_to_java_props()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function gradle.transform_to_java_props {
    local sysProps=""
    echo "1 $1"
    while IFS= read -r line; do
      trimLine=$(trim "$line")
      # if value of $var starts with #, ignore it
      [[ $trimLine =~ ^#.* ]] && continue
      # if its empty then move on
      [[ -z "$trimLine" ]] && continue
  
      sysProps+="-D$trimLine "
    done <<< "$1"
  
    echo "$sysProps"
  }
  ~~~

  <details>

## basic tempalate variable replacement using heredoc

## init_env

### make_env()

LEAVE THIS INDENT, heredoc needs to to look this way

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function make_env {
    make_env_init "${1:-}"
    createEnvFile
  }
  ~~~

  <details>

### make_env_init()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function make_env_init {
    setVar BUILD_ENV "${1:-test}"
    init_env
    init_db_env  #if DBMS env is set
  }
  ~~~

  <details>

### init_env()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function init_env {
    version=${version:-}
    [ "$version" ] && init_versions
  
    logit.info "init_env start with version $version"
  
    # if we passed in a file name
    # load_env "${env:-}"
  
    # if we pass in an sh to brute force it
    load_custom_sh_or_env
    # sh="${sh:-}"
    # if [ "${sh}" ]; then
    #   logit.info "Sourcing file ${sh}"
    #   source "${sh}"
    # fi
  
    # if a developer has a local dotenv then bring it in
    load_env ".env"
  
    # if build/vault/bot.env has been cloned this will import the vars
    # parse_bot_env_file
  
    # check for a build.env
    load_env "build.env"
  
    # if this is running in circle then this will normailze ENV variables to ours
    circle_init_env
  
    # imports vars from the build.yml
    init_from_build_yml
  
    # defaults
    init_defaults # call again after init_from_build_yml
  
    # kubernetes wants lower case so to comply we make some of them lower
    make_some_vals_lowercase
  
    if declare -f "post_init" > /dev/null; then
      # call post init function if it exists
      post_init
    fi
  }
  ~~~

  <details>

### init_defaults()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function init_defaults {
    set +u
    # important to remeber that setVar registers the var in BUILD_VARS
    # but only sets the passed in value when the variable is unset or empty
    PROJECT_FULLNAME="${PROJECT_FULLNAME:-}" # default to empty if not set
    [ ! "$PROJECT_FULLNAME" ] && project_fullname_from_git_remote
    add_build_vars PROJECT_FULLNAME
  
    # defaults the project name to the part after last /, so if fullname is 'foo/bar' then project name will be 'bar'
    setVar PROJECT_NAME "${PROJECT_FULLNAME##*/}"
  
    # logit.info "APP_NAME-$APP_NAME"
    setVar APP_NAME "${PROJECT_NAME}"
    # the dir where the app is, defaults to the root of the project
    setVar APP_DEPLOY_SRC "./deploy"
    setVar APP_DOCKER_SRC "${APP_DEPLOY_SRC}/docker"
    setVar APP_KUBE_SRC "${APP_DEPLOY_SRC}/kube"
  
    setVar APP_KEY "${APP_NAME}"
  
    # if dry_run then force PUBLISHABLE_BRANCH to the current git branch.
    if [[ "${dry_run:-}" ]]; then
      local cur_branch=$(current_git_branch)
      setVar PUBLISHABLE_BRANCH "$cur_branch"
      # PUBLISHABLE_BRANCH_OR_DRY_RUN can be true even if it is a snapshot
      setVar PUBLISHABLE_BRANCH_OR_DRY_RUN true
      logit.info "dry_run enabled, current_git_branch=$cur_branch PUBLISHABLE_BRANCH=$PUBLISHABLE_BRANCH "
    fi
  
  
    # default the releasable branch pattern and changelog name
    setVar PUBLISH_BRANCH_REGEX "master|dev|release/.+"
    setVar RELEASE_CHANGELOG "CHANGELOG.md"
    if [[ "${ACTIVE_BRANCH:-}" && "${ACTIVE_BRANCH}" =~ ^(${PUBLISH_BRANCH_REGEX})$ ]]; then
      setVar PUBLISHABLE_BRANCH "$ACTIVE_BRANCH"
    fi
  
    # can have dev publishable dev or snapshot branches that only release snapshots,
    # make sure they always set it snapshot
    setVar PUBLISH_BRANCH_DEVREGEX "dev"
    if [[ "${PUBLISHABLE_BRANCH:-}" =~ ^(${PUBLISH_BRANCH_DEVREGEX})$ && $(bool "${IS_SNAPSHOT:-}") = false ]]; then
      logit.info "****** version.snapshot SHOULD BE FALSE on dev branch"
      logit.info "****** Setting IS_SNAPSHOT=true since on dev branch"
      set_snapshot
    fi
  
    # shellcheck disable=SC2034
    IS_RELEASABLE='' #IS_RELEASABLE will be true if its NOT a snapshot and on a releasable branch
    if [[ "${PUBLISHABLE_BRANCH:-}" && $(bool "${IS_SNAPSHOT:-}") = false ]]; then
      setVar IS_RELEASABLE true
    fi
  
    # PUBLISHABLE_BRANCH_OR_DRY_RUN can be true even if it is a snapshot
    if [[ "${dry_run:-}" || "${PUBLISHABLE_BRANCH:-}" ]]; then
      setVar PUBLISHABLE_BRANCH_OR_DRY_RUN true
    fi
  
    # sets up defaults for PAGES if they are not setup already
    setVar PAGES_BUILD_DIR "$BUILD_DIR/gh-pages"
    setVar PAGES_BRANCH "gh-pages"
  
  }
  ~~~

  <details>

### init_from_build_yml()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function init_from_build_yml {
    # if gradle
    if [ -e ./build.yml ]; then
      # creates the variables from build.yml, exclude certain keys that are for gradle only
      yaml.load "./build.yml" true "" "MAVEN|CODENARC|SPOTLESS"
      BUILD_VARS+=" ${YAML_VARS[*]} "
    fi
    return 0 # I don't understand why this is needed
  }
  ~~~

  <details>

### make_some_vals_lowercase()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function make_some_vals_lowercase {
    set +u
    [ "$APP_KEY" ] && APP_KEY=$(tolower "${APP_KEY}")
    [ "$APP_DOCKER_URL" ] && APP_DOCKER_URL=$(tolower "$APP_DOCKER_URL")
    [ "$APP_KUBE_INGRESS_URL" ] && APP_KUBE_INGRESS_URL=$(tolower "$APP_KUBE_INGRESS_URL")
    [ "$APP_KUBE_DB_SERVICE_NAME" ] && APP_KUBE_DB_SERVICE_NAME=$(tolower "$APP_KUBE_DB_SERVICE_NAME")
    set -u
  }
  ~~~

  <details>

### init_versions()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function init_versions {
    # if nothing passing in the usee the lowercase version that should have come in from version.properties
    # local ver=${1:-$version}
    logit.debug "init_versions version $version, VERSION ${VERSION:-}"
    setVar VERSION "$version"
    setVar PUBLISHED_VERSION "${publishedVersion:-}"
  
    # shellcheck disable=SC2153 # Possible misspelling
    # cuts to the last dot
    local baseVersion="${VERSION%.*}"
  
    # VERSIONX is used for docker and k8s as we deploy latests minor version
    # also used to connect to the latest compatible database when that is relevant
    setVar VERSIONX "$baseVersion.x"
    #replace dots with - so 10.0.x turns into v10-0-x. k8s can't have dots in names
    setVar VERSIONX_DOTLESS "v${VERSIONX//./-}"
  
    putVar BUILD_VERSION "$VERSION"
  
    # if its a snapshot then append the SNAPSHOT
    if truthy "${snapshot:-}" || falsy "${release:-}"; then
      set_snapshot
    fi
  
    return 0
  }
  ~~~

  <details>

### set_snapshot()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function set_snapshot {
    putVar VERSION_SUFFIX "-SNAPSHOT"
    putVar IS_SNAPSHOT true
    BUILD_VERSION+="-SNAPSHOT"
    VERSIONX_DOTLESS+="-SNAPSHOT"
  }
  ~~~

  <details>

### circle_init_env()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function circle_init_env {
    CIRCLECI="${CIRCLECI:-}" # default to empty
    # if CIRCLE_BRANCH is set then consider it setup
    if [ "$CIRCLECI" ]; then
      setVar CI true
      setVar ACTIVE_BRANCH "$CIRCLE_BRANCH"
      setVar PROJECT_FULLNAME "${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}"
      # setVar GIT_REPO_URL "$CIRCLE_REPOSITORY_URL"
    elif truthy "${SUPER_DEV:-}"; then
      local cur_branch=$(current_git_branch)
      setVar ACTIVE_BRANCH "$cur_branch"
    fi
  }
  ~~~

  <details>

### init_db_env()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function init_db_env {
    if [ ! "${DBMS:-}" ]; then
      return 0
    fi
    # arg $1 must always be the database, defaults to mysql if nothing specified
    setVar DBMS "$DBMS"
    setVar DOCK_DB_BUILD_NAME "$DBMS-build"
  
    # **** DB Vars (MYSQL by default) ****
    setVar DB_HOST 127.0.0.1
    setVar DB_PORT 3306
    # PASS_VAR_NAME is the environment variable name that the docker dbs require. will be different based on vendor
    setVar PASS_VAR_NAME "MYSQL_ROOT_PASSWORD"
  
    if [ "$DBMS" == "mysql" ]; then
      PASS_VAR_NAME="MYSQL_ROOT_PASSWORD"
      DB_PORT=3306
    elif [ "$DBMS" == "sqlserver" ]; then
      PASS_VAR_NAME="SA_PASSWORD"
      DB_PORT=1433
    elif [ "$DBMS" == "postgresql" ]; then
      PASS_VAR_NAME="POSTGRES_PASSWORD"
      DB_PORT=5432
    fi
  
    if [ "${USE_DOCKER_DB_BUILDER:-}" = "true" ]; then
      setVar DockerDbExec "docker exec ${DOCK_DB_BUILD_NAME}"
      # if /.dockerenv this is inside a docker (such as circleCI) already
      # then we don't want to run docker in dockers, so blank it out
      if [ -f /.dockerenv ] || [ "${CI:-}" == "true" ]; then
        DockerDbExec=""
      fi
    fi
  
    # if we are inside the docker builder but not in circleCI force the DB_HOST
    if [ -f /.dockerenv ] && [ "${CI:-}" != "true" ]; then
      setVar DB_HOST "${DOCK_DB_BUILD_NAME}"
    fi
  }
  ~~~

  <details>

### createEnvFile()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function createEnvFile {
    local env_file="$MAKE_ENV_FILE" # exported from shipkit-main
    local env_file_dir="$(dirname "$env_file")"
    mkdir -p "$env_file_dir"
  
    echo "# ----- Generated from init_env --------" > "$env_file"
    for varName in $BUILD_VARS; do
        val=${!varName}
        echo "$varName=$val" >> "$env_file"
    done
    echo "BUILD_VARS=$BUILD_VARS" >> "$env_file"
    logit.debug "created $env_file"
  }
  ~~~

  <details>

### parse_bot_env_file()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function parse_bot_env_file {
    local bot_env="build/vault/bot.env"
    if [ -f $bot_env ]; then
      logit.info "loading bot.env file $bot_env"
      #change this once we have it sqaured away so exported env vars always win
      dotenv.load $bot_env true
    fi
  }
  ~~~

  <details>

### load_env()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function load_env {
    local protectedVars="PUBLISHABLE_BRANCH|ACTIVE_BRANCH|VERSION|VERSIONX|IS_SNAPSHOT"
    if [ -f "$1" ]; then
      logit.info "loading env file $1"
      dotenv.load "$1" false "$protectedVars"
    fi
  
  }
  ~~~

  <details>

### load_custom_sh_or_env()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function load_custom_sh_or_env {
    # if we pass in an sh to brute force it
    sh_env="${env:-}"
    if [ "${sh_env}" ]; then
      if [ ! -f "$sh_env" ]; then
        logit.error "[ env file not found:${sh_env} ]"
        return 1
      elif [[ "${sh_env}" == *.env ]]; then
        load_env "${sh_env}"
      elif [[ "${sh_env}" == *.sh ]]; then
        logit.info "Sourcing file ${sh_env}"
        source "${sh_env}"
      else
        logit.error "[ invalid env file: file name must end in either .env or .sh ]"
        return 1
      fi
    fi
  }
  ~~~

  <details>

## jbuilder_docker

### builderStart()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function builderStart {
    durl=${2:-"yakworks/builder:jdk8"}
    # the .gradle-docker volume map is so that it keeps the gradle cache in your home dir
    # so we dont need to down load the internet each new docker instance
    docker.start "$1" -it -d \
      -w /project \
      -p 8081:8080 \
  	  -v "$(pwd)":/project:delegated  \
  		-v ~/.gradle-docker/:/root/.gradle:delegated \
  		"$durl"
  }
  ~~~

  <details>

### db_start()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function db_start {
    # ACCEPT_EULA is for sql server, just an env var so won't matter that its set for others
    docker.start "$1" \
      --network builder-net \
      -v "$(pwd)":/project -w /project \
      -e ACCEPT_EULA=Y \
      -p "$3"  \
      -e "$4" \
      -d "$2"
  }
  ~~~

  <details>

### db-start()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function db-start {
    # env doesn't matter here so just set it to dev
    init_env dev "${1:-mysql}"
    db_start "${DOCK_DB_BUILD_NAME}" "${DOCKER_DB_URL}" "${DB_PORT}":"${DB_PORT}" "${PASS_VAR_NAME}"="${DB_PASSWORD}"
  }
  ~~~

  <details>

### wait_for_mysql()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function wait_for_mysql {
    host=${1:-127.0.0.1}
    echo "wait for mysql ..."
    while ! mysql -h "$host" --user=root --password="$2" -e "SELECT 1" >/dev/null 2>&1; do
      sleep 1
    done
  }
  ~~~

  <details>

### wait_for_sqlserver()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function wait_for_sqlserver {
    host=${1:-localhost}
    #/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'xxxx' -Q 'SELECT Name FROM sys.Databases'
    # sqlcmd -S $host -U SA -P $SA_PASSWORD -Q 'SELECT 1;'
    # for some reason sqlcmd needs to be fully qualified path for it to work on circleci
    while ! /opt/mssql-tools/bin/sqlcmd -S "$host" -U SA -P "$2" -Q 'SELECT Name FROM sys.Databases' >/dev/null 2>&1; do
      sleep 1
    done
  }
  ~~~

  <details>

## runs sed on the kubernetes tpl.yml template files to update and replace variables with values

### kube.process_tpl()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function kube.process_tpl {
    # set the variables in BUILD_ENV so we can build the sed replacement for templates
    # dotenv.load "build/make/makefile${MAKELEVEL}.env"
    heredoc_tpl "$1" "build/kube"
  }
  ~~~

  <details>

### kube.create_namespace()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function kube.create_namespace {
    [ "${dry_run:-}" ] && echo "🌮 dry_run ->  kube.ctl create namespace $1" && return 0
  
    if [ ! "$(kubectl get ns | grep "$1" || true)" ]; then
      kube.ctl create namespace "$1"
    fi
  }
  ~~~

  <details>

### kube.ctl()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function kube.ctl {
    if [ "${dry_run:-}" ]; then
  		echo "🌮 dry_run ->  kubectl $@"
  	else
  		kubectl "$@"
  	fi
  }
  ~~~

  <details>

### kube.apply()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function kube.apply {
    echo "$1" | kube.ctl apply -f -
  }
  ~~~

  <details>

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

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function makechecker.lint {
    makechecker.find_targets "$@"
    makechecker.lint_files "${MAKECHECK_TARGETS[@]}"
  }
  ~~~

  <details>

### makechecker.lint_files()

Lint one or more files

* __🔌 Args__

  * __$@__ (any): {array} list of files

* __📺 Stdout__

  * # @returns

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function makechecker.lint_files {
    local targets=("$@")
    local problems=""
    for f in "${targets[@]}"; do
      # echo "checking $f"
      fourSpaces="$(grep -n "^    [^#]" "$f" || true)"
      if [ "$fourSpaces" ]; then
        echo "$f has lines that start with 4 spaces instead of a tab"
        echo "$fourSpaces"
        problems="$fourSpaces"
      fi
    done
    if [ "$problems" ]; then
      return 1
    fi
  }
  ~~~

  <details>

### makechecker.find_targets()

gets all files that either start with Makefile or have .make extension

* __🔌 Args__

  * __$@__ (any): {array} one or more dirs

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function makechecker.find_targets {
    MAKECHECK_TARGETS=()
    for dir in "$@"; do
      while IFS=  read -r -d $'\0'; do
        if [[ "$REPLY" == *.make ]]; then
          MAKECHECK_TARGETS+=("$REPLY")
          # echo "got $REPLY"
          # grep "^    " "$REPLY" || true
        fi
      done < <(find "${dir}" -type f -print0)
    done
  }
  ~~~

  <details>

## basic tempalate variable replacement using sed

### build_sed_args()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function build_sed_args {
    for varName in $BUILD_VARS; do
      local escaped_var_name=$(printf '%s\n' "${!varName}" | sed -e 's/[\|&]/\\&/g')
      BUILD_VARS_SED_ARGS+="s|\\\${$varName}|$escaped_var_name|g; "
    done
    # echo "$BUILD_VARS_SED_ARGS"
  }
  ~~~

  <details>

## semver

### replace_version()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function replace_version {
    sed -i.bak -e "s|Version: [0-9.]*[-v]*[0-9.]*|Version: ${1}|g" "$2" && \
      rm -- "${2}.bak"
  
    # updatedContent = updatedContent.replaceFirst(/${p.name}:[\d\.]+[^"]+/, "${p.name}:$version")
    # update any dependencies for plugin style versions, ie `id "yakworks.gorm-tools" version "1.2.3"`
    # updatedContent = updatedContent.replaceFirst(/(?i)${p.name}"\sversion\s"[\d\.]+[^\s]+"/, "${p.name}\" version \"$version\"")
  }
  ~~~

  <details>

### bump_version_file()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function bump_version_file {
    local publishingVersion="${1}"
    local newVersion=$( bump_patch "$publishingVersion")
    local versionFile=${2:-version.properties}
    updateVersionFile "$newVersion" "$publishingVersion" "$versionFile"
    update_package_json "$newVersion"
  }
  ~~~

  <details>

### update_package_json()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function update_package_json {
    if [ -f package.json ]; then
      sed -i.bak -e "s|\"version\":.*|\"version\": \"${1}\",|g" package.json && rm -- "package.json.bak"
      # add it so it gets picked up in the push
      git add package.json
    fi
  }
  ~~~

  <details>

### updateVersionFile()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function updateVersionFile {
    local versionFile=${3:-version.properties}
    if [ -n "$1" ] ; then
      sed -i.bak \
        -e "s/^version=.*/version=$1/g"  \
        -e "s/^publishedVersion=.*/publishedVersion=$2/g" \
        "$versionFile"
      # remove the backup
      rm -f "${versionFile}.bak"
  
      # if snapshot was passed
      if truthy "${VERSION_SET_SNAPSHOT:-}" && grep -q ^snapshot= "$versionFile"; then
        sed -i.bak -e "s/^snapshot=.*/snapshot=true/g" "$versionFile" && rm "${versionFile}.bak"
      fi
      if truthy "${RELEASE_RESET_FLAG:-}" && grep -q ^release= "$versionFile"; then
        sed -i.bak -e "s/^release=.*/release=false/g" "$versionFile" && rm "${versionFile}.bak"
      fi
  
  
    else
      echo "ERROR: missing version parameter " >&2
      return 1
    fi
  }
  ~~~

  <details>

### bump_patch()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function bump_patch {
    local ver="${1}"
    local dotCount=$(echo "${ver}" | awk -F"." '{print NF-1}')
    # cuts to the last dot
    local baseVersion=$(echo "$ver" | cut -d. -f1-"$dotCount")
    # echo "major_and_minor $major_and_minor"
    local endPathLoc=$((dotCount+1))
    # grabs last part of version number
    local patch=$(echo "$ver" | cut -d. -f$endPathLoc)
    patchInc=$((patch + 1))
    ver=$(printf "%s.%d" "$baseVersion" "$patchInc")
    echo "$ver"
  }
  ~~~

  <details>

## setVar

### setVar()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function setVar {
    set +u # allow unbound variables
    varName="$1"
    # varVal="$2"
    # curVal="${!varName}"
    # [[ ! ${!varName+x} ]]
    if [[ -z ${!varName} ]]; then
      # logit.info "$varName=\"\$2\""
      eval "$varName=\"\$2\""
    fi
    add_build_vars "$varName"
    set -u # don't allow unbound variables
  }
  ~~~

  <details>

### evalVar()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function evalVar {
    varName="$1"
    # echo "$varName=\"$2\""
    eval "$varName=\"$2\""
    add_build_vars "$varName"
  }
  ~~~

  <details>

### putVar()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function putVar {
    # declare -g "$1"="$2" # not working in older bash 3 on mac
    eval "$1"=\$2
    add_build_vars "$1"
  }
  ~~~

  <details>

### add_build_vars()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function add_build_vars {
    for bvar in "$@"; do
      if [[ ! $BUILD_VARS == *" $bvar "* ]]; then
        # echo "adding $bvar to BUILD_VARS"
        BUILD_VARS+="$bvar "
      fi
    done
  }
  ~~~

  <details>

### log-vars()

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function log-vars {
    sorted=$(printf "%s\n" "$BUILD_VARS" | sort)
    for varName in $sorted; do
      echo "$varName = ${!varName}"
    done
  }
  ~~~

  <details>

## runs the shellcheck on the passed one or more directories

### shellcheck.lint_fix()

uses the pattern `shellcheck -f diff bin/* | git apply` to fix what can be automatically fixed

$@ - {array} one or more dirs

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function shellcheck.lint_fix {
    find_shellcheck_targets "$@"
  	shellcheck -f diff "${SHELLCHECK_TARGETS[@]}" | git apply
  }
  ~~~

  <details>

### find_shellcheck_targets()

collects the files names from one or more directories into SHELLCHECK_TARGETS variable
will recursively spin in and only get the files that are x-shellscript mime type

$@ - {array} one or more dirs

* <details> <summary><kbd> ℹ️ show function source</kbd></summary>

  ~~~bash
  function find_shellcheck_targets {
    SHELLCHECK_TARGETS=()
    for dir in "$@"; do
      while IFS=  read -r -d $'\0'; do
        if [[ "$(file --mime-type "$REPLY")" == *x-shellscript* ]]; then
          SHELLCHECK_TARGETS+=("$REPLY")
        fi
      done < <(find "${dir}" -type f -print0)
    done
  }
  ~~~

  <details>


