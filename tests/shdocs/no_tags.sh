#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

###
# simple.sh
# =========
#
# * description line1
# * description line2
#
# ```
#   got it
# ```

##
# foo go
foo.go() {
  echo
}

## foo set
foo.set() {
  echo foo
}

# picks up simple docs
normal() {
  echo 1
  # @description foo
  echo 2
}

# some foo
# @arg $1 string Some arg.
echo "foo"

# another one
# @arg $1 string Some arg.
normal2() {
  echo 1
  # @description foo
  echo 2
}
