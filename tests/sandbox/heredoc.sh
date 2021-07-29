#!/usr/bin/env bash
set -e
# uo pipefail # strict mode https://bit.ly/36MvF0T

# playing with concepts from here
# https://stackoverflow.com/questions/2914220/bash-templating-how-to-build-configuration-files-from-templates-with-bash
# for createing bash templates

FOO1=foo1
FOO2=foo2
FOO3=foo3

# eval "cat <<< \"$(<play.yml)\""

eval "cat <<EOF
$(<play.yml)
EOF
"
