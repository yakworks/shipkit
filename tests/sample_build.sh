#!/usr/bin/env bash
# main bash build script for CI, dev and releasing. Used in Makefile
set -e  # Abort script at first error
source ../bin/init_env # main init script

setVar BOT_EMAIL 9cibot@9ci.com


# --- boiler plate function runner, keep at end of file ------
# check if first param is a functions
if declare -f "$1" > /dev/null; then
  init_env # initialize standard environment, reads version.properties, build.yml , etc..
  "$@" #call function with arguments verbatim
else # could be that nothing passed or what was passed is invalid
  [ "$1" ] && echo "'$1' is not a known function name" >&2 && exit 1
fi
