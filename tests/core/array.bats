#!/usr/bin/env bats
load ../test_helper
core.import "array"
# alias array.contains="array::contains"

@test 'array contains' {
  alist=("a" "b" "c")
  array.contains "c" ${alist[@]}

  run array.contains "d" "${alist[@]}"
  assert_failure 1
  # [ $status = 1 ]

  run array.contains
  assert_failure 2
  assert_output --partial 'Missing arguments'
  # set -e
  # assert_equal $? 1

  # assert_failure 1
}

@test 'core.unique' {
  skip
  # local foo="a\nb\na\nb\nc\nb\nc"
  local foo=(zoo lion zoo tiger)
  local foo_sorted=(lion tiger zoo)
  local origIFS="$IFS"
  IFS=$'\n'
  local sorted=$(core.unique "${foo[@]}")
  echo sorted "${sorted[*]}"
  assert_equal "${sorted[*]}" "${foo_sorted[*]}"
  IFS="$origIFS"
}
