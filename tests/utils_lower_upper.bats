#!/usr/bin/env bats
source "$SHIPKIT_BIN/core/utils"
load test_helper
setup_file() { echo_test_name; }

@test 'tolower' {
  FOO="MaKe LoWeR"
  res=`tolower "MaKe LoWeR"`
  [ "$res" = "make lower" ]
}

@test 'toupper' {
  res=`toupper "MaKe uPpEr"`
  [ "$res" = "MAKE UPPER" ]
}
