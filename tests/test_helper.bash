#!/bin/bash
# Load dependencies.
load "build/installs/bats-support/load.bash"
load "build/installs/bats-assert/load.bash"

source "$SHIPKIT_BIN/core/main"

export OLD_PATH=$PATH

unset_term() {
  unset TERM
}

# makes the fixtures/bin come first so we can override and stub out programs
fixtures_bin() {
  export PATH=fixtures/bin:$PATH
  #export PATH=$BATS_TEST_DIRNAME/fixtures/bin:$PATH
}

# $1 - the dir name for the fixture
fixtures() {
  export FIXTURES_ROOT="$BATS_TEST_DIRNAME/fixtures/$1"
  export PATH=$FIXTURES_ROOT/bin:$PATH
}

echo_test_name() {
  echo "# Test $(basename ${BATS_TEST_FILENAME})" >&3
}

__debug() {
  printf '===> status <===\n%s\n' "$1"
  shift
  printf '===> output <===\n%s\n' "$1"
  shift
  echo "===> lines <==="
  locallines=("${@}")
  for i in ${!locallines[@]}; do
    echo "$i: ${locallines[$i]}"
  done
}
