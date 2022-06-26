#!/usr/bin/env bats
load test_helper
setup_file() { echo_test_name; }

setup() {
  export FIXTURE_DIR="$BATS_TEST_DIRNAME/fixtures/gradle"
  export PATH=$FIXTURE_DIR/bin:$PATH
  export PROJECT_SUBPROJECTS="foo bar"
}

teardown() {
  PATH=$OLD_PATH
}

@test 'gradle.resolve-dependencies' {
  run make -f $FIXTURE_DIR/Makefile gradle.resolve-dependencies
  assert_success
  assert_output --partial 'mock-gradlew resolveConfigurations'
  # assert_equal "${lines[0]}" "mock-gradlew resolveConfigurations --no-daemon"
}

@test 'gradle.merge-test-results' {
  target_name="$BATS_TEST_DESCRIPTION"
  run make -f $FIXTURE_DIR/Makefile $target_name
  assert_success
  assert_output --partial "[$target_name] completed"
  # assert_equal "${lines[0]}" "mock-gradlew resolveConfigurations --no-daemon"
}

@test 'gradle.cache-key-file' {
  target_name="$BATS_TEST_DESCRIPTION"
  run make -f $FIXTURE_DIR/Makefile $target_name
  assert_success
  assert_output --partial "[$target_name] completed"
  # assert_equal "${lines[0]}" "mock-gradlew resolveConfigurations --no-daemon"
}

@test 'ship.libs' {
  target_name="$BATS_TEST_DESCRIPTION"
  run make -f $FIXTURE_DIR/Makefile $target_name PUBLISHABLE_BRANCH=
  assert_success
  assert_output --partial "not a PUBLISHABLE_BRANCH"
  # assert_equal "${lines[0]}" "mock-gradlew resolveConfigurations --no-daemon"
}

@test 'ship.libs-relesabale' {
  target_name=ship.libs
  run make -f $FIXTURE_DIR/Makefile $target_name PUBLISHABLE_BRANCH=true
  assert_success
  assert_output --partial "[ship.libs] completed"
}

