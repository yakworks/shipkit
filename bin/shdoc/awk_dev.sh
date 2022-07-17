#!/bin/sh
SHDOC_DEBUG=1 awk -f ./bin/shdoc/github_styles.awk -f ./bin/shdoc/shdoc.awk  tests/shdocs/pod.sh
