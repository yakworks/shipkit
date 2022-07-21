#!/bin/sh

# shopt -s globstar
SHDOC_DEBUG=1 awk -f ./bin/shdoc/github_styles.awk -f ./bin/shdoc/shdoc.awk  tests/shdocs/pod.sh
# if shopt -q globstar; then
#         ...
# fi
