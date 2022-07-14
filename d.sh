#!/usr/bin/env bash
set -eo pipefail # strict mode https://bit.ly/36MvF0T

# helper for current dev functions, just a shell scratch bad for debugging

SHDOC_DEBUG=1 awk -f ./bin/shdoc/github_styles.awk -f ./bin/shdoc/shdoc.awk  tests/shdocs/no_tags.sh
# make test-bats TESTS=shdocs
