#!/usr/bin/env bats
load test_helper

MAKEFILE="
include Shipkit.make

test1: | _program_whatever
	@echo you should not see this

test2: | _program_make
	@echo you should most definitly see this

test3: | _verify_WHATEVER
	@echo you should not see this

FOO = bar
test4: | _verify_FOO
	@echo you should most definitely see this
"

@test 'shipkit.make executes without errors' {
  run make -f Shipkit.make
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
}

@test 'shipkit.make _program_% fails when command is not found' {
  run make -f <(echo "$MAKEFILE") test1
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 2 ]
  [[ "${lines[0]}" =~ "`whatever` command not found" ]]
}

@test 'shipkit.make _program_make should find the make command' {
  run make -f <(echo "$MAKEFILE") test2
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "you should most definitly see this" ]
}

@test 'shipkit.make _verify_% fails when the env var is not defined' {
  run make -f <(echo "$MAKEFILE") test3
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 2 ]
  [[ "${lines[0]}" =~ "`WHATEVER` is not defined or is empty" ]]
}

@test '_verify_FOO should not fail' {
  run make -f <(echo "$MAKEFILE") test4
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "you should most definitely see this" ]
}
