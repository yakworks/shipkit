#!/usr/bin/env bash

# @file simple.sh
# @description descline1

###
# simple a
a() {
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
