#!/bin/bash
# @description Same, as `tests.eval`, but writes stdout into given variable and
# return stderr as expected.
#
# @example
#   _x() {
#       echo "y [$@]"
#   }
#   tests:value response _x a b c
#   tests:assert-equals "$response" "y [a b c]"
#
# @arg $1 string Variable name.
# @arg $@ string String to evaluate.
# @see tests.eval
# @see foo()
tests.value() {
    local __variable__="\$1"
    local __value__=""
    shift

    tests:ensure "${@}"

    __value__="$(cat "$(tests:get-stdout-file)")"
    eval $__variable__="${__value__}"
}

# @description foo should work
function foo() {
  echo bar
}
