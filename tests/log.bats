#!/usr/bin/env bats
load test_helper
setup_file() { echo_test_name; }

setup() {
  fixtures log
  unset_term
}

teardown() {
  PATH=$OLD_PATH
}

@test 'log callable produces sensible output with TERM set' {
  export TERM=xterm
  run make -f $FIXTURES_ROOT/Makefile test1
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
  [ "$(cat -vet <(echo $output))" == "^[[1m===> the test1 target ^[(B^[[m$" ]
}

@test 'log callable produces sensible output without TERM' {
  run make -f $FIXTURES_ROOT/Makefile test1
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
  [ "$(cat -vet <(echo ${lines[0]}))" == "===> the test1 target$" ]
}
