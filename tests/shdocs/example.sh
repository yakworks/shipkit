#!/usr/bin/env bash
# @name example.sh
# @brief Brief description here
# @description more here
#  * with lists
#  * of things

###
# Multiline description goes here
# and here
#
# @example
#   some:other:func a b c
#   echo 123
#
# @arg $1 string Some arg.
# @arg $@ any Rest of arguments.
#
# @set RETVAL string Variable was set
#
# @exitcode 0  If successfull.
# @exitcode >0 Failure
# @exitcode 5  some specific error.
#
# @stdin Path to something.
# @stdout Path to something.
#
# @see some.other.func()
do.something() {
  echo
}

# @description can use description tag too
# @example
#   echo "using example tag"
#   echo 2
b() {
  echo
}

# @description func b
# ab
# @noargs
c() {
  echo
}

# @description func c
# @example
#     echo 1
#     echo 2
c() {
  echo
}

###
# triple desc
trip() {
  echo
}
