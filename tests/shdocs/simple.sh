#!/usr/bin/env bash

###
# simple.sh
# =========
# descline1

###
# simple a
function a {
  echo
}

# @description desc b
b() { echo foo; }

# picks up simple docs
normal() {
  echo 1
}

# @internal use if dont want it to show
bar() { echo; }
