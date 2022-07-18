#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

##
# pod.sh - simple example of how a _script_ can be documented - for testing
# =========================================================================
# pod = Plain Old Documentation. Its a term from the perl days and it smiliar to man
# Will be able to generate man pages from it ot setup right

##
# documenting function without tags. keep it easy to read. Sticks to a markdownish like context
# can provide a quick example inline like `pod.sh go "$bar"`
#
# ARGS:
# - $1 - make it easy to comment on vars, can also use indents instead of markdown lists
# - $2 - type in the docs will default to string
#
function pod.go() {
  echo
}

##
# more complex example
#
# ```bash
#   echo "code fenced examples have the benefit if setup right of being formated in editor such as vscode"
# ```
#
# ARGS:
#   $1 - (number) args can be indented if you prefere a cleaner style
#   $2 - (can_be_whatever) the specified types can be anything
#   $@ - remaining args
#
# @arg $3 - can still use the arg tag
# @errorcode >0 - can use error codes or use @exitcode
function pod.go:faster() {
  echo
}

