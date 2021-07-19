#!/usr/bin/env bats

# converted to bats format from what is here https://github.com/jasperes/bash-yaml
source "$SHIPKIT_BIN/utils"

@test 'tolower' {
  FOO="MaKe LoWeR"
  res=`tolower "MaKe LoWeR"`
  [ "$res" = "make lower" ]
}

@test 'toupper' {
  res=`toupper "MaKe uPpEr"`
  [ "$res" = "MAKE UPPER" ]
}
