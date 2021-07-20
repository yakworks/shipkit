#!/usr/bin/env bats
source "$SHIPKIT_BIN/utils"

@test 'isFalsy isTruthy when FOO=any value' {
  FOO="any value"

  [ ! $(isFalsy "$FOO") ]
  [ $(isTruthy "$FOO") ]
}

@test 'isFalsy isTruthy when FOO is unset' {
  unset FOO

  [ $(isFalsy "$FOO") ]
  [ ! $(isTruthy "$FOO") ]
}

@test 'isFalsy isTruthy when FOO= nothing, empy' {
  FOO=

  [ $(isFalsy "$FOO") ]
  [ ! $(isTruthy "$FOO") ]
}

@test 'isFalsy isTruthy when FOO=false or FOO="false"' {
  FOO=false
  [ $(isFalsy "$FOO") ]
  [ ! $(isTruthy "$FOO") ]

  FOO="false"
  [ $(isFalsy "$FOO") ]
  [ ! $(isTruthy "$FOO") ]
}

@test 'isFalsy isTruthy when FOO=0 or FOO="0"' {
  FOO=0
  [ $(isFalsy "$FOO") ]
  [ ! $(isTruthy "$FOO") ]

  FOO="0"
  [ $(isFalsy "$FOO") ]
  [ ! $(isTruthy "$FOO") ]
}
