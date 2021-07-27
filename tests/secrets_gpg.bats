#!/usr/bin/env bats
load test_helper

setup() {
  export FIXTURE_DIR="$BATS_TEST_DIRNAME/fixtures/secrets"
  export GPG_PRIVATE_KEY=`echo s3cr3t | base64`
  export BOT_EMAIL=9cibot@9ci.com
}

teardown() {
  PATH=$OLD_PATH
}

@test 'make sure git-secret-version works' {
  run make -f $FIXTURE_DIR/Makefile git-secret-version
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
  # [ "${lines[0]}" == "tests/fixtures/bin/curl  \"http://localhost\" | cat -" ]
}

@test 'should work in a different dir too' {
  run make -f $FIXTURE_DIR/Makefile version-cd-dir
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
}

@test 'secrets.import-gpg-key' {
  PATH=$FIXTURE_DIR/bin:$PATH
  run make -f $FIXTURE_DIR/Makefile secrets.import-gpg-key
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "importing GPG KEY" ]
  [ "${lines[1]}" == "mock-gpg s3cr3t" ]
}
