#!/usr/bin/env bats
source "$SHIPKIT_BIN/core/utils"
load test_helper

@test 'tolower' {
  FOO="MaKe LoWeR"
  res=`tolower "MaKe LoWeR"`
  [ "$res" = "make lower" ]
}

@test 'toupper' {
  res=`toupper "MaKe uPpEr"`
  [ "$res" = "MAKE UPPER" ]
}
