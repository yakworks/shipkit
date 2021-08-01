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
}

@test 'log callable produces sensible output without TERM' {
  run make -f $FIXTURES_ROOT/Makefile test1
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
}
