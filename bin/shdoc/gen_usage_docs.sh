#!/usr/bin/env bash
set -eo pipefail # strict mode https://bit.ly/36MvF0T

# helper for current dev functions, just a shell scratch bad for debugging

# SHDOC_DEBUG=1 awk f ./bin/shdoc/shdoc.awk  tests/shdocs/no_tags.sh
# make test-bats TESTS=shdocs
shopt -s globstar
awk -v MULTI_FILE=1 -f ./bin/shdoc/shdoc.awk -f ./bin/shdoc/shdoc_fns.awk bin/* > test.md
