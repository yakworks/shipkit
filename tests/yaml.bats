#!/usr/bin/env bats
# converted to bats format from what is here https://github.com/jasperes/bash-yaml
source "$SHIPKIT_BIN/core/yaml"
load test_helper

setup() {
  echo "BATS_TMPDIR ${BATS_TMPDIR}"
  # load_yaml_variables "${BATS_TEST_DIRNAME}/fixtures/testing.yml"
}

@test 'check with caps and excludes pattern' {
  APP_NAME="" # null out APP_NAME so yamls sets it
  APP_KEY=""
  SOME_ENV_VAR="go go go"
  yaml.load "${BATS_TEST_DIRNAME}/fixtures/build.yml" true "" "MAVEN|CODENARC|SECRET"
  # size should be 7 because of what we excluded
  assert_equal "${#YAML_VARS[@]}" 8
  assert_equal "$TITLE" "Project Title"
  assert_equal "$APP_NAME" "some-name"
  assert_equal "$APP_KEY" "some-name-key"
  assert_equal "$APP_SOME_VAR" "go go go"
  assert_equal "$APP_KUBE_NFS" "10.10.10.10"
  assert_equal "${ARRAY_TEST2[*]}" "foo bar"
}

@test 'the big verify' {
  yaml.load "${BATS_TEST_DIRNAME}/fixtures/testing.yml"

  [ "$person_name" = "Jon athan" ] &&
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
