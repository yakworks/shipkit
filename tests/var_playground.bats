#!/usr/bin/env bats
load test_helper

source "$SHIPKIT_BIN/core/utils"

# SEE https://github.com/bats-core/bats-assert
# refute tests that its false. assert tests that its true
@test 'When FOO is unset' {
  VarName=FOO
  set +u #allow unbound
  assert [ -z "$FOO" ] # FOO unset and empty 1
  [ ! "$FOO" ] # FOO unset and empty 2a
  [ ! $FOO ] # The defaults is -n, so this is ! -n
  [ -z ${FOO+set} ] # -z and ! are same thing
  [ ! ${FOO+set} ] # FOO is unset, using ! 4"
  # checking VarName that has the name of the variable
  [ ! ${!VarName+set} ]

  # these will NOT be true
  refute [ $FOO ] # default is -n
  refute [ -n "$FOO" ] # default is -n so does not need to be here
  refute [ ${FOO+set} ]

  ! [[ $FOO && $FOO != "" ]] || false
  FOO2=bar
  [[ $FOO2 && $FOO2 != "" ]] || false

  refute [ "${!VarName}" ]
  refute [ ${!VarName+set} ]

  falsy "$FOO"
  ! truthy "$FOO"

  refute [ "${FOO:-}" = "BOO" ]
  # this is false because $FOO is not wrapped in "",
  # If you don't quote the variable expansion and the variable is undefined or empty,
  # it vanishes from the scene of the crime, leaving only [ = ""]
  # refute picks up the failure
  refute [ $FOO = "" ]
  # this works because it evaluated to [ "" = ""]
  assert [ "$FOO" = "" ]
  # double brackets do it for you and deal with variable expansion automatically
  [[ $FOO = "" ]] || false
  # works as well as expected
  [[ "$FOO" = "" ]] || false
}

@test 'When FOO is empty string' {
  set -u
  VarName=FOO
  FOO=""
  [ -z "$FOO" ] # FOO unset and empty 1"
  [ ! $FOO ] # The defaults is -n, so this is ! -n
  # These will NOT be true now as they only pick up unset but Foo is empty string now
  refute [ -z ${FOO+set} ]
  refute [ ! ${FOO+set} ]
  # checking VarName that has the name of the variable
  refute [ ! ${!VarName+set} ]

  # Will NOT be true as empty string is not truthy
  refute [ $FOO ]
  refute [ "$FOO" ]
  # Will be true now as its empty string
  [ ${FOO+set} ]
  [[ $FOO || $FOO = "" ]] || false

  # will NOT be true
  refute [ ${!VarName} ]
  refute [ "${!VarName}" ]
  # Will be true now as its empty string
  [ ${!VarName+set} ]

  # empty string is falsy
  falsy "$FOO" || fail "should be falsy"
  ! truthy "$FOO" || fail "should not be truthy"
  assert [ $(isFalsy "$FOO") ]
  refute [ ! "$(isFalsy "$FOO")" ]

  [[ "$FOO" = "" ]] || false
  [[ "${FOO:-}" = "" ]] || false
}

@test 'When FOO = bar' {
  FOO="bar"
  VarName=FOO
  # will NOT be true now
  refute [ -z "$FOO" ]
  refute [ ! $FOO ]
  refute [ -z ${FOO+set} ]
  refute [ ! ${FOO+set} ]

  # checking VarName that has the name of the variable
  refute [ ! ${!VarName+set} ]

  # Will be true now
  [ $FOO ]
  [ "$FOO" ]
  [ ${FOO+set} ]
  [[ $FOO || $FOO == "" ]] || false
  [ ${!VarName} ]
  [ "${!VarName}" ]
  [ ${!VarName+set} ]

  # truthy falsy
  falsy "$FOO" && fail 'should not get here as foo is not truthy now'
  truthy "$FOO"
  [ ! $(isFalsy "$FOO") ]


  [[ "$FOO" = "bar" ]] || false
  [[ "${FOO:-}" = "bar" ]] || false


}
