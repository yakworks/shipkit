#!/usr/bin/env bats
source "$SHIPKIT_BIN/bashify/utils"
load test_helper
setup_file() { echo_test_name; }

@test 'truthy when someVal=any value' {
  someVal="any value"

  if falsy $someVal; then
    fail 'should not get here as foo is not falsy'
  fi

  falsy $someVal && fail 'should not get here as foo is not falsy'

  TruthyWorkedHere=no
  truthy $someVal && TruthyWorkedHere=yes
  assert_equal "$TruthyWorkedHere" "yes"

  run truthy $someVal
  assert_success

  [ $(bool "$someVal") = "true" ]
}

@test 'falsy when FOO is unset' {
  set +u # turn off/ allow unbound variable check
  unset someVal

  if truthy $someVal; then
    fail 'should never get here as someVal is falsy'
  fi

  run falsy $someVal
  assert_success

  [ $(bool "$someVal") = "false" ]
  set +u # turn it back on
}

@test 'falsy when FOO= nothing, empy' {
  someVal=""

  if truthy $someVal; then
    fail 'should never get here as someVal is falsy'
  fi

  run falsy $someVal
  assert_success

  [ $(bool "$someVal") = "false" ]
}

@test 'falsy when FOO=false or FOO="false"' {
  someVal=false
  run falsy $someVal
  assert_success

  [ $(bool "$someVal") = "false" ]


  someVal="false"
  run falsy $someVal
  assert_success
  [ $(bool "$someVal") = "false" ]
}

@test 'falsy when FOO=0 or FOO="0"' {
  someVal=0
  run falsy $someVal
  assert_success

  [ $(bool "$someVal") = "false" ]

  someVal="0"
  run falsy $someVal
  assert_success

  [ $(bool "$someVal") = "false" ]
}

@test 'combo' {
  FOO="0"; BAR=42
  echo -e "\nCombo falsy FOO=false and BAR=42"
  # double brackets allow use to have && ||
  t1=0;t2=0;t3=0
  if falsy "$FOO" && truthy "$BAR"; then
    t1=1
  fi
  [[ $(isFalsy "$FOO") && $BAR = 42 ]] && t2=1
  [[ $(isFalsy "$FOO") && (($BAR > 40)) ]] && t3=1
  truthy "$FOO" && [[ $BAR = 42 ]] && fail "should not fail"

  assert_equal $t1 1
  assert_equal $t2 1
  assert_equal $t3 1
}
