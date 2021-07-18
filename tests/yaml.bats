#!/usr/bin/env bats

# tconverted to bats format from what is here https://github.com/jasperes/bash-yaml

load _test_base
source "$SHIPKIT_BIN/yaml"

setup() {
  # echo "BATS_TMPDIR ${BATS_TMPDIR}"
  create_yml_variables "${BATS_TEST_DIRNAME}/fixtures/testing.yml"
}

@test 'simple list items' {

  # listItems="${sample_lists[*]}"
  # # echo "# listItems ${listItems}" > &3
  # for item in $listItems; do
  #     echo "# item in list $item" >&3
  # done
  [ "${#thingList[@]}" = 3 ]
  [ "${thingList[0]}" = "foo" ]
}

@test 'the big verify' {
  [ "$person_name" = "Jonathan" ] &&
  [ "$person_age" = "99" ] &&
  [ "$person_email" = "jonathan@email.com" ] &&

  [ "${persons__name[0]}" = "'Maria'" ] &&
  [ "${persons__age[0]}" = "'88'" ] &&
  [ "${persons__email[0]}" = "'maria@email.com'" ] &&

  [ "${persons__name[1]}" = "\"João\"" ] &&
  [ "${persons__age[1]}" = "\"77\"" ] &&
  [ "${persons__email[1]}" = "\"joao@email.com\"" ] &&

  [ "$complex_test_simple_obj_attr" = "\"value\"" ] &&
  [ "$complex_test_simple_obj_other_attr" = "other \"value\"" ] &&
  [ "$complex_test_simple_obj_http" = "http://some.endpoint.com" ] &&

  [ "${complex_test_simple_obj_chaos_list__attr[0]}" = "value1" ] &&
  [ "${complex_test_simple_obj_chaos_list__otherv[0]}" = "value1v" ] &&
  [ "${complex_test_simple_obj_chaos_list__attr[1]}" = "value2" ] &&
  [ "${complex_test_simple_obj_chaos_list__otherv[1]}" = "\"value2v\"" ] &&

  # test_list "${complex_test_simple_obj_a_list[*]}" &&

  [ "$more_tests_double_dashes" = "--ok" ] &&
  [ "$more_tests_dot_start" = ".dot" ] &&
  [ "$more_tests_some_propertie" = "some-propertie ok!" ] &&
  [ "$more_tests_domain_com" = "domain.com ok!" ] &&
  [ "$more_tests_inline_comment" = "something" ] &&
  [ "$more_tests_comment_with_hash" = "an#hash" ] &&
  [ "$more_tests_hash" = "a#hash" ] &&

  [ "$more_tests_single_quotes_hash1" = "'a#hash'" ] &&
  [ "$more_tests_single_quotes_hash2" = "'a   #hash'" ] &&
  [ "$more_tests_single_quotes_hash3" = "'#hi'" ] &&
  [ "$more_tests_single_quotes_comment_in_string" = "'a string...'" ] &&

  [ "$more_tests_double_quotes_hash1" = "\"a#hash\"" ] &&
  [ "$more_tests_double_quotes_hash2" = "\"a   #hash\"" ] &&
  [ "$more_tests_double_quotes_hash3" = "\"#hi\"" ] &&
  [ "$more_tests_double_quotes_comment_in_string" = "\"a string...\"" ] &&
  [ "$more_tests_a_multi_dash_property" = "result-is=OK" ] &&
  [ "$more_tests_a_multi_dot_property" = "result.is=OK" ] &&
  [ "$more_tests_a_property_that_has_quite_a_number_of_dashes" = "result-is=OK" ] &&
  [ "$more_tests_a_property_that_has_dashes_and_dots" = "result-is.absolutely=fine.and-perfect" ] 
}

# Functions
function test_list() {
    local list=$1

    if is_debug; then
        echo "All values from list: ${list[*]}";
    fi

    x=0
    for i in ${list[*]}; do
        if is_debug; then
            echo "Item: $i";
        fi

        [ "$i" = "$x" ] || return 1
        x="$((x+1))"
    done

    if is_debug; then echo; fi
}

@test 'test complex list' {
 test_list "${complex_test_simple_obj_a_list[*]}"
}
