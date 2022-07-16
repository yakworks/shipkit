#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

##
# foo go
foo.go() {
  echo
}

## foo set
foo.set() {
  echo foo
}

# normal comment used when GREEDY
normal() {
  echo 1
  # @description foo
  echo 2
}

# some foo
# @arg $1 should avoid mistakes and throw this away
echo "foo"

# another one
# @arg $1 string Some arg.
normal2() {
  echo 1
  # @description foo
  echo 2
}
