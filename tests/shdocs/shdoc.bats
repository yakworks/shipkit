#!/usr/bin/env bats
source "$SHIPKIT_BIN/core/main"
load ../test_helper

###
# Tests the shdocs awk.
# uses diff to make errors easier to see.
# if you only see something like 7c6 then that means blnk line 7 in first is missing from under line 6 in other.
# so test file manualy and kick to console use something like below:
# SHDOC_DEBUG=1 ./bin/shdoc/shdoc.awk < tests/shdocs/example.sh

setup() {
  shdocAwk=$SHIPKIT_BIN/shdoc/shdoc.awk
}

run_shdoc(){
 run $SHIPKIT_BIN/shdoc/shdoc.awk < "$BATS_TEST_DIRNAME/${1}"
}

diff_output(){
  # local expect_md=$(cat $BATS_TEST_DIRNAME/${1})
  # if [[ $output != $expect_md ]]; then
  #   __debug "${status}" "${output}" "${lines[@]}"
  # fi
  # dif returns error code 1 if they are different and will fail test
  # but also show the results of the diff making it easy to see where its different on failure
  diff <(echo "$output") "$BATS_TEST_DIRNAME/${1}"
}

@test 'script 1 check' {
  run_shdoc example.sh
  diff_output example.md
}

@test 'set tags' {
  run_shdoc set.sh
  diff_output set.md
}

@test 'using the @ variable' {
  run_shdoc func_at.sh
  diff_output func_at.md
}

@test 'no_toc' {
  run awk -v toc=false -f $SHIPKIT_BIN/shdoc/shdoc.awk < "$BATS_TEST_DIRNAME/simple.sh"
  diff_output simple.md
}
