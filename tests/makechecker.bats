#!/usr/bin/env bats
source "$SHIPKIT_BIN/makechecker"
load test_helper

setup() {
  export FIXTURE_DIR="$BATS_TEST_DIRNAME/fixtures/versions"
}

@test 'makechecker.lint should fail on bad file' {
  run makechecker.lint "$BATS_TEST_DIRNAME/fixtures/bad.make"
  assert_failure
  [ "${lines[1]}" == "5:    this will fail" ]
}
