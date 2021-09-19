Uses bats https://github.com/bats-core/bats-core

`make test` will run the tests

## asserts

from https://github.com/bats-core/bats-assert

`assert [ -e '/var/log/test.log' ]`

refute
Fail if the given expression evaluates to true.
refute [ -e '/var/log/test.log' ]

assert_equal
Fail if the two parameters, actual and expected value respectively, do not equal.
assert_equal 'have' 'want'

assert_success
Fail if $status is not 0.

assert_failure
Fail if $status is 0.

assert_output
run echo 'have'
assert_output 'want'
run echo 'some SUCCESS xxx'
assert_output --partial 'SUCCESS'

assert_line
run echo $'have-0\nwant\nhave-2'
assert_line 'want'
