#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

##
# pod.sh - simple example of how a _script_ can be documented - for testing
# =========================================================================
# pod = Plain Old Documentation. Its a term from perl the days.
# Its often used to generate man pages and has been around a long while.

##
# foo go
#
# ```
#   echo
#   echo
# ```
#
#
# @arg $1 string Variable name.
# @arg $2 (string) String to evaluate.
# @arg $2 - (string) String to evaluate.
# @arg $2 - (string) String to evaluate.
# @arg $@ - remaining args.
#
# @errorcode >0 - Failures
# @errorcode 5  - some specific error.
foo.go() {
  echo
}

