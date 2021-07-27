#!/usr/bin/env bats

source "$SHIPKIT_BIN/bashify/utils"

@test 'trim with leading spaces' {
  FOO="  some value"
  trimmed=$(trim "$FOO")
  [ "$trimmed" = "some value" ]
}

@test 'trim with trailing spaces' {
  FOO="some value   "
  trimmed=$(trim "$FOO")
  [ "$trimmed" = "some value" ]
}

@test 'trim with both trailing and leading spaces' {
  FOO="    some value    "
  trimmed=$(trim "$FOO")
  [ "$trimmed" = "some value" ]
}

@test 'trim with both trailing and leading spaces and tabs' {
  FOO=$(echo -e " \t  some value  \t  ")
  trimmed=$(trim "$FOO")
  echo "trimmed=$trimmed;"
  [ "$trimmed" = "some value" ]
}
