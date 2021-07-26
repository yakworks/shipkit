#!/usr/bin/env bats
source "$SHIPKIT_BIN/core"
load test_helper

@test 'core.rel_path' {

    [ $(core.rel_path "/A/B/C" "/A/B/C") = "." ]

    [ $(core.rel_path "/A/B/C" "/A") = "../.." ]

    [ $(core.rel_path "/A/B/C" "/A/B") = ".." ]

    [ $(core.rel_path "/A/B/C" "/A/B/C/D") = "D" ]

    [ $(core.rel_path "/A/B/C" "/A/B/C/D/E") = "D/E" ]

    [ $(core.rel_path "/A/B/C" "/A/B/D") = "../D" ]
}

@test 'core.unique' {
  # skip
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

