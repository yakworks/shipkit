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

cat <<EOF
line1
line2
EOF

eval "cat <<EOF
$(<heredoc.yml)
EOF
" > processed.yml
