#!/usr/bin/env bash
# @name example.sh
# @brief Brief here, can be usage
# @description more here
#  * with lists
#  * of things
#
# ```bash
#   example.sh something -f text.txt
# ```

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
  # func comment
  echo
# @description bad comment will not get picked up or heredoc
# heredoc fine too
  eval cat << EOF
# @description foo
EOF
# bad formatting
foo || {
  echo
}
}

# @description can use description tag too
# @example
#   echo "using example tag"
#   echo 2
# @noargs
noargs() {
  echo
}

# @description func c
# @example
#     echo 1
#     echo 2
c() {
  echo
}

##
# triple desc
trip() {
  echo
}
