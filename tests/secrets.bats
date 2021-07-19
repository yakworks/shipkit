#!/usr/bin/env bats
load test_helper

MAKEFILE='
include ./Shipkit.make
include makefiles/secrets.make

version-cd-dir: 
	cd build && $(GIT_SECRET_SH) --version
'

@test 'make sure git-secret-version works' {
  run make -f <(echo "$MAKEFILE") git-secret-version
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
  # [ "${lines[0]}" == "tests/fixtures/bin/curl  \"http://localhost\" | cat -" ]
}

@test 'should work in a different dir too' {
  run make -f <(echo "$MAKEFILE") version-cd-dir
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
  # [ "${lines[0]}" == "tests/fixtures/bin/curl  \"http://localhost\" | cat -" ]
}

