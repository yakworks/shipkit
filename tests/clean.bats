#!/usr/bin/env bats
load test_helper.bash
#fixtures_bin
# export PATH=fixtures/bin:$PATH

MAKEFILE="
include Shipkit.make

.PHONY: clean
clean::
	rm -rf /tmp/__one__.clean /tmp/__two__.clean

"

LOG="build/test.log"

setup() {
  echo "$BATS_TEST_NAME" >> "$LOG"
  PATH=$BATS_TEST_DIRNAME/fixtures/bin:$PATH
  echo "$PATH" >> "$LOG"
}

teardown() {
  PATH=$OLD_PATH
}

@test 'shipkit.make clean attempts to cleanup the contents' {
  run make --no-print-directory -f <(echo "$MAKEFILE") clean
  __debug "${status}" "${output}" "${lines[@]}"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "mock-rm -rf /tmp/__one__.clean /tmp/__two__.clean" ]
}
